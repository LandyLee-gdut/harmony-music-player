import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import CryptoJS from '@ohos/crypto-js'; // 需要引入 MD5 库，用于生成唯一文件名
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { MediaTools } from './MediaTools';
import { image } from '@kit.ImageKit';
import { PixelMapItem } from './MediaTools'
const TAG = 'ImageCacheUtils'

export default  class ImageCacheUtils {
  private static instance: ImageCacheUtils;
  private cacheDir: string;
  private downloadingMap: Map<string, Promise<string>> = new Map(); // 跟踪正在下载的图片

  private constructor(context: common.UIAbilityContext) {
    // 获取缓存目录
    this.cacheDir = context.cacheDir;
    // 确保缓存目录存在
    if (!fs.accessSync(this.cacheDir)) {
      fs.mkdirSync(this.cacheDir);
    }
  }

  // 单例模式
  public static getInstance(context?: common.UIAbilityContext): ImageCacheUtils {
    if (!ImageCacheUtils.instance && context) {
      ImageCacheUtils.instance = new ImageCacheUtils(context);
    }
    return ImageCacheUtils.instance;
  }

  // 根据 URL 生成缓存文件名
  private getCacheFileName(url: string): string {
    const cacheDir = this.cacheDir;
    const fileName = url.split('/').pop() || CryptoJS.MD5(url).toString();
    Logger.info(TAG, 'return path: ' + `${cacheDir}/${fileName}`)
    return `${cacheDir}/${fileName}`;
  }

  // 获取图片缓存路径
  public async getCachedImagePath(url: string): Promise<string> {
    if (!url) {
      Logger.error(TAG, 'failed to get cached image path')
      return this.getDefaultPlaceholderPath(); // 返回默认占位符路径
    }

    const cachePath = this.getCacheFileName(url);

    // 检查缓存是否存在
    if (fs.accessSync(cachePath)) {
      Logger.info(TAG, 'find cache:' + cachePath)
      return cachePath; // 缓存存在，直接返回路径
    }

    // 检查是否正在下载
    if (this.downloadingMap.has(url)) {
      Logger.info(TAG, 'downloading image from url:' + url)
      return this.downloadingMap.get(url)!; // 返回正在下载的 Promise
    }

    // 开始下载图片
    const downloadPromise = this.downloadImage(url, cachePath)
      .then((path) => {
        this.downloadingMap.delete(url); // 下载完成，移除记录
        Logger.info(TAG, 'successfully download file from url:' + url + ' and the path is ' + path)
        return path;
      })
      .catch((err: BusinessError) => {
        this.downloadingMap.delete(url); // 下载失败，移除记录
        Logger.error(TAG, 'fail to download file from url:' + url + ` error:${err}`)
        return this.getDefaultPlaceholderPath(); // 返回默认占位符路径
      });

    this.downloadingMap.set(url, downloadPromise);
    return downloadPromise;
  }

  // 优化后的下载和缓存方法
  private async downloadImage(url: string, cachePath: string): Promise<string> {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER, // 明确请求 ArrayBuffer
      });

      if (response.responseCode !== 200 || !response.result || response.resultType !== http.HttpDataType.ARRAY_BUFFER) {
        Logger.error(TAG, 'Download failed: Invalid response');
        throw new Error('Download failed');
      }

      const imageData = response.result as ArrayBuffer;
      Logger.info(TAG, `Downloaded image data size: ${imageData.byteLength} bytes`);

      // 检查文件大小是否超过 5MB
      const maxSize = 1 * 1024 * 1024; // 5MB
      if (imageData.byteLength <= maxSize) {
        // 如果小于 5MB，直接写入缓存
        const file = fs.openSync(cachePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
        fs.writeSync(file.fd, imageData);
        fs.closeSync(file);
        Logger.info(TAG, `Image cached to: ${cachePath} (size: ${imageData.byteLength} bytes)`);
        return cachePath;
      }

      // 如果大于 5MB，创建缩略图并压缩
      Logger.warn(TAG, `Image size (${imageData.byteLength} bytes) exceeds 5MB, creating thumbnail`);
      const imageSource = image.createImageSource(imageData);
      if (!imageSource) {
        throw new Error('Failed to create ImageSource from network data');
      }

      // 获取原始图片信息
      const imageInfo = await imageSource.getImageInfo();
      Logger.info(TAG, `Original image size: ${imageInfo.size.width}x${imageInfo.size.height}`);

      // 计算缩略图尺寸，确保文件大小小于 5MB
      const thumbnailSize = this.calculateThumbnailSize(imageInfo.size as PixelMapItem, maxSize);
      Logger.info(TAG, `Thumbnail size: ${thumbnailSize.width}x${thumbnailSize.height}`);

      // 创建缩略图 PixelMap
      const options: image.InitializationOptions = {
        editable: false, // 不可编辑以节省内存
        pixelFormat: image.PixelMapFormat.RGBA_8888, // 使用标准 RGBA 格式
        alphaType: image.AlphaType.OPAQUE, // 无透明度，减少内存使用
        scaleMode: image.ScaleMode.CENTER_CROP, // 居中裁剪适配尺寸
        size: thumbnailSize, // 动态计算的缩略图尺寸
      };

      const thumbnailPixelMap: PixelMap = await imageSource.createPixelMap(options);
      if (!thumbnailPixelMap) {
        throw new Error('Failed to create thumbnail PixelMap');
      }

      // 压缩并写入磁盘（降低质量以确保小于 5MB）
      const thumbnailBuffer = await MediaTools.pixelMapToBuffer(thumbnailPixelMap, 10); // 降低质量到 60
      const file = fs.openSync(cachePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, thumbnailBuffer);
      fs.closeSync(file);

      Logger.info(TAG, `Compressed thumbnail cached to: ${cachePath}, size: ${thumbnailBuffer.byteLength} bytes`);
      return cachePath;
    } catch (error) {
      Logger.error(TAG, `Image download failed: ${JSON.stringify(error)}`);
      throw new Error('Image download failed');
    }
  }

  // 计算缩略图尺寸，确保文件大小不超过 maxSize
  private calculateThumbnailSize(originalSize: PixelMapItem, maxSize: number): PixelMapItem {
    let width = 100; // 默认宽度
    let height = 100; // 默认高度

    // 按比例缩放，确保宽高比接近原始图片
    const aspectRatio = originalSize.width / originalSize.height;
    if (width / height > aspectRatio) {
      width = Math.round(height * aspectRatio);
    } else {
      height = Math.round(width / aspectRatio);
    }

    // 估计缩略图大小（假设每像素 4 字节，RGBA_8888）
    const estimatedSize = width * height * 4;
    if (estimatedSize > maxSize) {
      // 进一步缩小，直到小于 maxSize
      const scale = Math.sqrt(maxSize / estimatedSize);
      width = Math.round(width * scale);
      height = Math.round(height * scale);
    }

    return { width, height };
  }
  // 获取默认占位符图片路径
   public getDefaultPlaceholderPath(): string {
    // 假设默认占位符图片存储在资源目录中，例如：
    return 'app.media.ic_dream';
  }
}