/*
 * Copyright (c) Yue 2024.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Created by Yue on 2024/6/25.
 */

import { HashMap } from '@kit.ArkTS';

export class Utils {
  /**
   * 任意类型转 json 字符串，不能转的返回空字符串 ""
   * @param json
   * @returns
   */
  public static jsonStringify(json: Object | undefined | null): string {
    if (json instanceof Map || json instanceof HashMap) {
      let obj: object = Utils.mapToObject(json);
      return JSON.stringify(obj);
    }
    try {
      let jsonStr = JSON.stringify(json);
      return (jsonStr.length > 0) ? jsonStr : "";
    } catch (e) {
      return "";
    }
  }

  /**
   * Map 转 Object
   * @param map
   * @returns
   */
  public static mapToObject(map: Map<Object, Object> | HashMap<Object, Object>): object {
    let obj: object = new Object();
    if (map instanceof Map) {
      map.forEach((value: Object, key: Object) => {
        if (value instanceof Map || value instanceof HashMap) {
          obj[key.toString()] = Utils.mapToObject(value);
        } else {
          obj[key.toString()] = value;
        }
      });
    }
    // 兼容 HashMap
    else if (map instanceof HashMap) {
      map.forEach((value: Object, key: Object) => {
        if (value instanceof Map || value instanceof HashMap) {
          obj[key.toString()] = Utils.mapToObject(value);
        } else {
          obj[key.toString()] = value;
        }
      });
    }
    return obj;
  }

  /// json 转 字典 Map
  public static jsonToMap(obj: Object | undefined | null): Map<string, Object> {
    let result: Map<string, Object> = new Map<string, Object>();
    // 传入的 obj 为空
    if (obj === undefined || obj === null) {
      return result;
    }

    // 传入的是 字符串
    if (typeof obj === 'string') {
      // 尝试用 json 对象接收
      try {
        let jsonObj: Object = JSON.parse(obj);
        // json 对象 是 字典
        if (jsonObj instanceof Map) {
          let jsonMap: Map<Object, Object> = jsonObj;
          jsonMap.forEach((value, key) => {
            result.set(key.toString(), value);
          });
        }
        // json 对象 不是 字典
        else {
          result = Utils.objToStrKeyMap(jsonObj);
        }
      } catch (e) {
      }
    }
    // 传入的本身就是 map
    else if (obj instanceof Map) {
      let objMap: Map<Object, Object> = obj;
      objMap.forEach((value, key) => {
        result.set(key.toString(), value);
      });
    }
    // 其他情况
    else {
      try {
        let resultMap: Map<string, Object> = new Map<string, Object>();
        let objMap: Map<Object, Object> = new Map<Object, Object>(Object.entries(obj));
        objMap.forEach((value, key) => {
          resultMap.set(key.toString(), value);
        });
        return resultMap;
      } catch (e) {
      }
    }
    return result;
  }

  /**
   * 传入任意 Object 类型，获得 Map<string, Object> 字典类型
   * @param obj 任意类型数据
   * @param def 默认值
   * @returns Map<string, Object> 字典类型
   */
  public static objToStrKeyMap(obj: Object | undefined | null, def?: Map<string, Object>): Map<string, Object> {
    let result: Map<string, Object> = def ?? new Map<string, Object>();
    // 传入的 obj 为空
    if (obj === undefined || obj === null) {
      return result;
    }

    // 是 Map 类型的
    if (obj instanceof Map) {
      let resultMap: Map<string, Object> = new Map<string, Object>();
      let objMap: Map<Object, Object> = obj as Map<Object, Object>;
      objMap.forEach((value, key) => {
        resultMap.set(key.toString(), value);
      });
      return resultMap;
    }
    // 是 字符串类型
    else if (typeof obj === 'string') {
      return (obj.length > 0) ? Utils.jsonToMap(obj) : result;
    }
    // 其他类型
    else {
      try {
        let resultMap: Map<string, Object> = new Map<string, Object>();
        let objMap: Map<Object, Object> = new Map<Object, Object>(Object.entries(obj));
        objMap.forEach((value, key) => {
          resultMap.set(key.toString(), value);
        });
        return resultMap;
      } catch (e) {
      }
    }
    return result;
  }
}
