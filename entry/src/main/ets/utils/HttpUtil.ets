/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { http } from '@kit.NetworkKit';
import ResponseResult from '../viewmodel/ResponseResult';
import { CommonConstant as Const, ContentType } from '../constant/CommonConstant';
/**
 * 封装一个基本的http请求
 *
 * @param get方法的请求地址
 * @param params Params for initiating an HTTP request.
 */
export function httpRequestGet(url: string): Promise<ResponseResult> {
  let httpRequest = http.createHttp();

  let responseResult = httpRequest.request(url, {
    method: http.RequestMethod.GET,
    readTimeout: Const.HTTP_READ_TIMEOUT,
    header: {
      'Content-Type': ContentType.JSON
    },
    connectTimeout: Const.HTTP_READ_TIMEOUT,
    extraData: {}
  });

  let serverData: ResponseResult = new ResponseResult();
  // Processes the data and returns.
  return responseResult.then((value: http.HttpResponse) => {
    console.log("Value" + JSON.stringify(value.result))
    if (value.responseCode === Const.HTTP_CODE_200) {
      // Obtains the returned data.
      let result = `${value.result}`;
      // 这里不能直接parse 会出现错误！
      let resultJson: ResponseResult = JSON.parse(result);
      serverData.data = resultJson.data;
      console.log("Data:" + resultJson.data)
      serverData.code = JSON.stringify(Const.HTTP_CODE_200);
      serverData.msg = resultJson.msg;
    } else {
      console.log("Http Result else:" + JSON.stringify(value))
      serverData.msg = `${$r('app.string.http_error_message')}&${value.responseCode}`;
    }
    return serverData;
  }).catch((err: Error) => {
    console.log("Http Result catch:" + JSON.stringify(err))
    serverData.msg = $r('app.string.http_error_message');
    return serverData;
  })
}