/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import ImageCacheUtils from '../utils/ImageCacheUtils'
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { Logger } from './Logger';
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';
const TAG = 'MediaTools';
export interface PixelMapItem { height: number; width: number }
export class MediaTools {

  private imageCacheUtils: ImageCacheUtils;

  constructor(context: common.UIAbilityContext) {
    this.imageCacheUtils = ImageCacheUtils.getInstance(context);
  }

  static async getPixelMapFromUrlWithCache(
    url: string,
    context: common.UIAbilityContext,
    thumbnailSize: PixelMapItem = { height: 100, width: 100 }
  ): Promise<image.PixelMap | undefined> {
    try {
      const cacheDir = context.cacheDir;
      const fileName = url.split('/').pop() || 'image.jpg';
      const cachePath = `${cacheDir}/${fileName}`;

      // 检查缓存是否存在
      if (fs.accessSync(cachePath)) {
        Logger.info(TAG, `Loading PixelMap from cache: ${cachePath}`);
        return await MediaTools.getPixelMapFromFile(cachePath);
      }

      // 下载网络图片
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
      });

      if (response.resultType !== http.HttpDataType.ARRAY_BUFFER) {
        Logger.error(TAG, 'Failed to get image data as ArrayBuffer');
        throw new Error('Failed to get image data as ArrayBuffer');
      }

      const imageData = response.result as ArrayBuffer;
      Logger.info(TAG, `Downloaded image data size: ${imageData.byteLength} bytes`);

      // 检查文件大小是否超过5MB
      const maxSize = 5 * 1024 * 1024; // 5MB
      if (imageData.byteLength > maxSize) {
        Logger.warn(TAG, `Image size (${imageData.byteLength} bytes) exceeds 5MB, creating thumbnail`);
      }

      // 创建 ImageSource
      const imageSource = image.createImageSource(imageData);
      if (!imageSource) {
        throw new Error('Failed to create ImageSource from network data');
      }

      // 获取原始图片信息（用于日志或调试）
      const imageInfo = await imageSource.getImageInfo();
      Logger.info(TAG, `Original image size: ${imageInfo.size.width}x${imageInfo.size.height}`);

      // 创建缩略图 PixelMap，使用详细的 InitializationOptions
      const options: image.InitializationOptions = {
        editable: false, // 不可编辑以节省内存
        pixelFormat: image.PixelMapFormat.RGBA_8888, // 使用标准 RGBA 格式
        alphaType: image.AlphaType.OPAQUE, // 无透明度，减少内存使用
        scaleMode: image.ScaleMode.CENTER_CROP, // 居中裁剪以适应缩略图尺寸
        size: thumbnailSize // 指定缩略图尺寸
      };

      const thumbnailPixelMap = await imageSource.createPixelMap(options);
      if (!thumbnailPixelMap) {
        throw new Error('Failed to create thumbnail PixelMap');
      }

      // 将缩略图写入磁盘
      const thumbnailBuffer = await MediaTools.pixelMapToBuffer(thumbnailPixelMap);
      const file = await fs.open(cachePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, thumbnailBuffer);
      await fs.close(file);

      Logger.info(TAG, `Thumbnail cached to: ${cachePath}, size: ${thumbnailBuffer.byteLength} bytes`);

      return thumbnailPixelMap;
    } catch (error) {
      Logger.error(TAG, `Failed to load PixelMap from URL: ${url}, error: ${JSON.stringify(error)}`);
      return undefined;
    }
  }

  // 辅助方法：从本地文件加载 PixelMap
  static async getPixelMapFromFile(filePath: string): Promise<image.PixelMap> {
    const imageSource = image.createImageSource(filePath);
    if (!imageSource) {
      throw new Error(`Failed to create ImageSource from file: ${filePath}`);
    }
    return await imageSource.createPixelMap();
  }

  // 辅助方法：将 PixelMap 转换为 ArrayBuffer
  static async pixelMapToBuffer(pixelMap: image.PixelMap, quality: number = 80): Promise<ArrayBuffer> {
    const packingOpts: image.PackingOption = {
      format: 'image/jpeg', // 使用 JPEG 格式，减小文件大小
      quality: quality, // 压缩质量
    };
    const imagePacker = image.createImagePacker();
    return await imagePacker.packing(pixelMap, packingOpts);
  }
  /**
   * 从本地资源加载 PixelMap
   * @param context UIAbilityContext
   * @param resource 资源标识（如 { id: number }）
   * @returns Promise<PixelMap>
   */
  static async getPixelMapFromResource(context: common.UIAbilityContext, resource: resourceManager.Resource): Promise<image.PixelMap> {
    try {
      const resourceMgr = context.resourceManager;
      const fileData: Uint8Array = await resourceMgr.getMediaContent(resource);
      const imageSource = image.createImageSource(fileData.buffer as ArrayBuffer);
      if (!imageSource) {
        throw new Error('Failed to create ImageSource from resource');
      }
      const pixelMap = await imageSource.createPixelMap();
      Logger.info(TAG, 'Successfully loaded PixelMap from resource');
      return pixelMap;
    } catch (error) {
      Logger.error(TAG, `Failed to load PixelMap from resource: ${JSON.stringify(error)}`);
      throw new Error();
    }
  }
  /**
   * 日期不足两位补 0
   *
   * @param {string} value - 数据值
   * @return {string} - 日期不足两位补 0
   */
  private static fill(value: number): string {
    return value.toString().padStart(2, '0');
  }

  static msToCountdownTime(ms: number): string {
    if (!ms) {
      return '00:00';
    }
    const days = Math.floor(ms / (1000 * 60 * 60 * 24));
    const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((ms % (1000 * 60)) / 1000);
    return `${(days ? MediaTools.fill(days) + ':' : '')}${(hours ? MediaTools.fill(hours) + ':' : '')}
      ${MediaTools.fill(minutes)}:${MediaTools.fill(seconds)} `.trim();
  }
}