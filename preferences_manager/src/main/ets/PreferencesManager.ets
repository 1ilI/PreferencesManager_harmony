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

import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { Utils } from './Utils';

/** 默认 preferences 的名称 */
const PREFERENCES_NAME: string = 'defaultPreferences';

/** 创建 PreferencesManager 所需参数 */
export interface CreateManagerParams {
  /** 可选参数，Context */
  preferencesContext?: Context;

  /** 可选参数，preferences 的名称 */
  preferencesName?: string;
}

export class PreferencesManager {
  public get preferences(): preferences.Preferences | undefined {
    return this._preferences;
  }

  private _preferencesContext: Context = getContext().getApplicationContext();
  private _preferencesName: string = PREFERENCES_NAME;
  private _preferences: preferences.Preferences | undefined;

  constructor(params?: CreateManagerParams) {
    if (params?.preferencesContext) {
      this._preferencesContext = params.preferencesContext;
    }
    if (params?.preferencesName) {
      this._preferencesName = params.preferencesName;
    }
    let options: preferences.Options = { name: this._preferencesName };
    this._preferences = preferences.getPreferencesSync(this._preferencesContext, options);
  }

  private static _defManager: PreferencesManager;

  /**
   * 默认的 PreferencesManager 实例
   * @returns
   */
  public static get defManager(): PreferencesManager {
    if (!this._defManager) {
      this._defManager = new PreferencesManager();
    }
    return this._defManager;
  }

  /**
   * 判断自定义的 manager 实例是否存在
   */
  public static hasManager(params: CreateManagerParams): boolean {
    let hasManager = false;
    if (params.preferencesName) {
      let options: preferences.Options = { name: params.preferencesName };
      let manager = preferences.getPreferencesSync(params.preferencesContext, options);
      if (manager) {
        hasManager = true;
      }
    }
    return hasManager;
  }

  /**
   * 移除 manager 实例
   * @param params
   */
  public static removeManager(params: CreateManagerParams) {
    if (params.preferencesName) {
      preferences.removePreferencesFromCacheSync(params.preferencesContext, params.preferencesName);
    }
  }

  /**
   * 清除所有数据
   */
  public clear() {
    this._preferences?.clearSync();
    this.flush();
  }

  /**
   * 删除对应 key 的数据
   * @param key
   */
  public delete(key: string) {
    this._preferences?.deleteSync(key);
    this.flush();
  }

  /**
   * 是否有对应 key 的数据
   * @param key
   * @returns
   */
  public has(key: string): boolean {
    return this._preferences?.hasSync(key) ?? false;
  }

  /**
   * 保存对应 key 的数据
   * @param key
   * @param value 数据
   * @param stringNeedEncode 若保存的是字符串，是否需要对字符串进行编码保存（转为保存 Uint8Array）
   */
  public save(key: string, value: preferences.ValueType, stringNeedEncode: boolean = false) {
    let saveValue = value;
    if (typeof value === "string" && stringNeedEncode) {
      saveValue = new util.TextEncoder().encodeInto(value);
    }
    this._preferences?.putSync(key, saveValue);
    this.flush();
  }

  /**
   * 获取对应 key 的数据
   * @param key
   * @param defValue 默认值
   * @param stringNeedDecode 若获取的是字符串，是否需要对字符串进行解码处理（按 Uint8Array 读，然后解码）
   * @returns
   */
  public get(key: string, defValue: preferences.ValueType,
    stringNeedDecode: boolean = false): preferences.ValueType | undefined {
    let getObj = this._preferences?.getSync(key, defValue);
    if (getObj instanceof Uint8Array && typeof defValue === "string" && stringNeedDecode) {
      getObj = new util.TextDecoder().decodeWithStream(getObj);
    }
    return getObj;
  }

  /**
   * 获取全部记录的值
   * @returns
   */
  public getAll(): Object | undefined {
    return this._preferences?.getAllSync();
  }

  /**
   * 获取对应 key 的字符串值
   * @param key
   * @param defValue 可自定义默认值，默认为空字符串 ""
   * @param stringNeedDecode 是否需要对字符串进行解码处理（按 Uint8Array 读，然后解码）
   * @returns
   */
  public getStringValue(key: string, defValue: string = "", stringNeedDecode: boolean = false): string {
    let getObj = this.get(key, defValue, stringNeedDecode);
    if (typeof getObj === "string") {
      return getObj;
    }
    return defValue;
  }

  /**
   * 获取对应 key 的数值值
   * @param key
   * @param defValue 可自定义默认值，默认为 -1
   * @returns
   */
  public getNumberValue(key: string, defValue: number = -1): number {
    let getObj = this.get(key, defValue);
    if (typeof getObj === "number") {
      return getObj;
    }
    return defValue;
  }

  /**
   * 获取对应 key 的布尔值
   * @param key
   * @param defValue 可自定义默认值，默认为 false
   * @returns
   */
  public getBoolValue(key: string, defValue: boolean = false): boolean {
    let getObj = this.get(key, defValue);
    if (typeof getObj === "boolean") {
      return getObj;
    }
    return defValue;
  }

  /**
   * 获取对应 key 的数组值
   * @param key
   * @param defValue 可自定义默认值，默认为空数组 []
   * @returns
   */
  public getArrayValue(key: string, defValue: Array<number | boolean | string> = []): Array<number | boolean | string> {
    let getObj: Array<number | boolean | string> = defValue;
    try {
      getObj = this.get(key, defValue) as Array<number | boolean | string>;
    } catch (e) {
    }
    return getObj;
  }

  /**
   * 获取对应 key 的 Uint8Array 数组的值
   * @param key
   * @param defValue 可自定义默认值，默认为空数组 []
   * @returns
   */
  public getUint8ArrayValue(key: string, defValue: Uint8Array = new Uint8Array(0)): Uint8Array {
    let getObj = this.get(key, defValue);
    if (getObj instanceof Uint8Array) {
      return getObj;
    }
    return defValue;
  }

  /**
   * 保存对应 key 的 Map 类型的数据
   * @param key
   * @param value Map 类型的数据
   */
  public saveMapValue(key: string, value: Map<string, Object>) {
    let jsonStr = Utils.jsonStringify(value);
    if (jsonStr.length) {
      this.save(key, jsonStr, true);
    }
  }

  /**
   * 获取对应 key 的 Map 类型的数据
   * @param key
   * @param defValue 可自定义默认值，默认为空字典 {}
   * @returns
   */
  public getMapValue(key: string, defValue: Map<string, Object> = new Map()): Map<string, Object> {
    let getJsonStr = this.getStringValue(key, '', true);
    if (getJsonStr.length) {
      return Utils.jsonToMap(getJsonStr);
    }
    return defValue;
  }

  /**
   * 订阅数据变更，订阅的数据发生变更后，在执行flush方法后，触发callback回调。
   * @param callback 回调
   */
  public onChange(callback: Callback<string>) {
    let observer = (key: string) => {
      callback(key);
    }
    this._preferences?.on('change', observer);
  }

  /**
   * 取消订阅数据变更。
   * @param callback 回调
   */
  public offChange(callback?: Callback<string>) {
    let observer = (key: string) => {
      if (callback) {
        callback(key);
      }
    }
    this._preferences?.off('change', observer);
  }

  /**
   * 订阅数据变更，订阅的数据发生变更后，在执行flush方法后，触发callback回调。
   * @param callback 回调
   */
  public onDataChange(keys: Array<string>, callback: Callback<Record<string, preferences.ValueType>>) {
    this._preferences?.on('dataChange', keys, (data: Record<string, preferences.ValueType>) => {
      callback(data);
    });
  }

  /**
   * 取消订阅指定数据变更。
   * @param keys 指定的 key 数组
   * @param callback
   */
  public offDataChange(keys: Array<string>) {
    this._preferences?.off('dataChange', keys);
  }

  /**
   * 订阅数据变更，订阅的数据发生变更后，在执行flush方法后，触发callback回调。
   * @param callback 回调
   */
  public onMapDataChange(keys: Array<string>, callback: Callback<Map<string, Map<string, Object>>>) {
    this._preferences?.on('dataChange', keys, (data: Record<string, preferences.ValueType>) => {
      let mapData: Map<string, Map<string, Object>> = new Map();
      for (const keyValue of Object.entries(data)) {
        let key = keyValue[0];
        let value = this.decodeToMap(keyValue[1]);
        mapData.set(key, value);
      }
      callback(mapData);
    });
  }

  /**
   * 取消订阅指定数据变更。
   * @param keys 指定的 key 数组
   * @param callback
   */
  public offMapChange(keys: Array<string>) {
    this._preferences?.off('dataChange', keys);
  }

  /**
   * 写入存储，数据持久化
   * @param callback
   */
  private flush() {
    this._preferences?.flush();
  }

  /**
   * 读出是 Uint8Array 的，decoder 一下为 json 字符串，然后转为 Map
   * @param value Map
   * @returns
   */
  private decodeToMap(value: preferences.ValueType): Map<string, Object> {
    let map: Map<string, Object> = new Map();
    try {
      let jsonStr = new util.TextDecoder().decodeWithStream(value as Uint8Array);
      map = Utils.jsonToMap(jsonStr);
    } catch (e) {
    }
    return map;
  }
}