//axiosClient.ets
//author:csdn猫哥(blog.csdn.net/qq8864)
import axios, { AxiosError, AxiosInstance, AxiosRequestHeaders, AxiosResponse, InternalAxiosRequestConfig } from "@ohos/axios";

interface HttpResponse<T> {
  data: T;
  status: number;
  statusText: string;
  config: HttpRequestConfig;
}

export type HttpPromise<T> = Promise<HttpResponse<T>>;

interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: any) => any;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: any) => any;
}


interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean; // 是否展示请求loading
  checkResultCode?: boolean; // 是否检验响应结果码
  checkLoginState?: boolean; // 校验用户登陆状态
  needJumpToLogin?: boolean; // 是否需要跳转到登陆页面
  interceptorHooks?: InterceptorHooks; // 拦截器
  headers: AxiosRequestHeaders | undefined;
  errorHandler?: (error: any) => void; // 错误处理
}

export class AxiosHttpRequest {
  config: HttpRequestConfig;
  interceptorHooks?: InterceptorHooks;
  instance: AxiosInstance;

  constructor(options: HttpRequestConfig) {
    this.config = options;
    this.interceptorHooks = options.interceptorHooks;
    this.instance = axios.create(options);
    this.setupInterceptor();
  }

  setupInterceptor(): void {
    this.instance.interceptors.request.use(
      this.interceptorHooks?.requestInterceptorCatch,
    );
    this.instance.interceptors.response.use(
      this.interceptorHooks?.responseInterceptor,
      this.interceptorHooks?.responseInterceptorCatch,
    );
  }

  request<T = any>(config: HttpRequestConfig): HttpPromise<T> {
    return new Promise<HttpResponse<T>>((resolve, reject) => {
      this.instance.request<any, HttpResponse<T>>(config)
        .then(res => {
          resolve(res);
        })
        .catch(err => {
          const errorHandler = config.errorHandler || errorHandlerDefault;
          errorHandler(err);
          reject(err);
        });
    });
  }

  get<T = any>(config: HttpRequestConfig): HttpPromise<T> {
    return this.request({ ...config, method: 'GET' });
  }

  post<T = any>(config: HttpRequestConfig): HttpPromise<T> {
    return this.request({ ...config, method: 'POST' });
  }

  delete<T = any>(config: HttpRequestConfig): HttpPromise<T> {
    return this.request({ ...config, method: 'DELETE' });
  }

  patch<T = any>(config: HttpRequestConfig): HttpPromise<T> {
    return this.request({ ...config, method: 'PATCH' });
  }
}

function errorHandlerDefault(error: any) {
  if (error instanceof AxiosError) {
    // 处理Axios的错误
    console.error('axios err occur:' + `error msg:${error}`)
  }
  // 处理其他类型的错误
  console.error('other error occur while using axios:' + `error msg:${error}`)
}

export default AxiosHttpRequest;