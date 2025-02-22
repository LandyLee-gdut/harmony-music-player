//axiosClient.ets
//author:csdn猫哥(blog.csdn.net/qq8864)
import {AxiosHttpRequest,HttpPromise} from './AxiosClient'
import {AxiosRequestHeaders,AxiosError } from '@ohos/axios';
import { Logger } from './Logger';
import { promptAction } from "@kit.ArkUI";

function showToast(msg:string){
  Logger.debug(msg)
  promptAction.showToast({ message: msg })
}

function showLoadingDialog(msg:string){
  Logger.debug(msg)
  promptAction.showToast({ message: msg })
}

function hideLoadingDialog() {

}
/**
 * axios请求客户端创建
 */
const axiosClient = new AxiosHttpRequest({
  baseURL: "http://1333480939-2nw0dhpsvz.ap-guangzhou.tencentscf.com",
  timeout: 20 * 1000,
  checkResultCode: false,
  showLoading:true,
  headers: {
    'Content-Type': 'application/json'
  } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config) => {
      // 在发送请求之前做一些处理，例如打印请求信息
      Logger.debug('网络请求Request 请求方法:', `${config.method}`);
      Logger.debug('网络请求Request 请求链接:', `${config.url}`);
      Logger.debug('网络请求Request Params:', `\n${JSON.stringify(config.params)}`);
      Logger.debug('网络请求Request Data:', `${JSON.stringify(config.data)}`);
      axiosClient.config.showLoading = config.showLoading
      if (config.showLoading) {
        showLoadingDialog("加载中...")
      }
      return config;
    },
    requestInterceptorCatch: (err) => {
      Logger.error("网络请求RequestError", err.toString())
      if (axiosClient.config.showLoading) {
        hideLoadingDialog()
      }
      return err;
    },
    responseInterceptor: (response) => {
      //优先执行自己的请求响应拦截器，在执行通用请求request的
      if (axiosClient.config.showLoading) {
        hideLoadingDialog()
      }
      Logger.debug('网络请求响应Response:', `\n${JSON.stringify(response.data)}`);
      if (response.status === 200) {
        // @ts-ignore
        const checkResultCode = response.config.checkResultCode
        if (checkResultCode && response.data.errorCode != 0) {
          showToast(response.data.errorMsg)
          return Promise.reject(response)
        }
        return Promise.resolve(response);
      } else {
        return Promise.reject(response);
      }
    },
    responseInterceptorCatch: (error) => {
      if (axiosClient.config.showLoading) {
        hideLoadingDialog()
      }
      Logger.error("网络请求响应异常", error.toString());
      errorHandler(error);
      return Promise.reject(error);
    },
  }
});
const axiosClientFlask = new AxiosHttpRequest({
  baseURL: "http://1333480939-dxkf8ofexh.ap-guangzhou.tencentscf.com",
  timeout: 20 * 1000,
  checkResultCode: false,
  showLoading:true,
  headers: {
    'Content-Type': 'application/json'
  } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config) => {
      // 在发送请求之前做一些处理，例如打印请求信息
      Logger.debug('网络请求Request 请求方法:', `${config.method}`);
      Logger.debug('网络请求Request 请求链接:', `${config.url}`);
      Logger.debug('网络请求Request Params:', `\n${JSON.stringify(config.params)}`);
      Logger.debug('网络请求Request Data:', `${JSON.stringify(config.data)}`);
      axiosClient.config.showLoading = config.showLoading
      if (config.showLoading) {
        showLoadingDialog("加载中...")
      }
      return config;
    },
    requestInterceptorCatch: (err) => {
      Logger.error("网络请求RequestError", err.toString())
      if (axiosClient.config.showLoading) {
        hideLoadingDialog()
      }
      return err;
    },
    responseInterceptor: (response) => {
      //优先执行自己的请求响应拦截器，在执行通用请求request的
      if (axiosClient.config.showLoading) {
        hideLoadingDialog()
      }
      Logger.debug('网络请求响应Response:', `\n${JSON.stringify(response.data)}`);
      if (response.status === 200) {
        // @ts-ignore
        const checkResultCode = response.config.checkResultCode
        if (checkResultCode && response.data.errorCode != 0) {
          showToast(response.data.errorMsg)
          return Promise.reject(response)
        }
        return Promise.resolve(response);
      } else {
        return Promise.reject(response);
      }
    },
    responseInterceptorCatch: (error) => {
      if (axiosClient.config.showLoading) {
        hideLoadingDialog()
      }
      Logger.error("网络请求响应异常", error.toString());
      errorHandler(error);
      return Promise.reject(error);
    },
  }
});
function errorHandler(error: any) {
  if (error instanceof AxiosError) {
    //showToast(error.message)
  } else if (error != undefined && error.response != undefined && error.response.status) {
    switch (error.response.status) {
    // 401: 未登录
    // 未登录则跳转登录页面，并携带当前页面的路径
    // 在登录成功后返回当前页面，这一步需要在登录页操作。
      case 401:

        break;
    // 403 token过期
    // 登录过期对用户进行提示
    // 清除本地token和清空vuex中token对象
    // 跳转登录页面
      case 403:
        //showToast("登录过期，请重新登录")
        // 清除token
        // localStorage.removeItem('token');
        break;
    // 404请求不存在
      case 404:
        //showToast("网络请求不存在")
        break;

    // 其他错误，直接抛出错误提示
      default:
    //showToast(error.response.data.message)
    }

  }
}

export  { axiosClient, HttpPromise, axiosClientFlask };