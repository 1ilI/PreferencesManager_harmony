import { PreferencesManager, Utils } from '@yue/preferences_manager'
import { promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string = "";

  aboutToAppear(): void {
    PreferencesManager.defManager.onChange((changedKey: string) => {
      this.message = '监听所有数据变更\n变更数据的 key 为：' + changedKey;
    });

    PreferencesManager.defManager.onDataChange(['stringKey'], (data: Record<string, preferences.ValueType>) => {
      this._toast('监听到指定 key 的数据变更：\n' + Utils.jsonStringify(data));
    });

    PreferencesManager.defManager.onMapDataChange(['mapKey'], (data: Map<string, Map<string, Object>>) => {
      this._toast('监听到指定 key 的数据变更(Map)：\n' + Utils.jsonStringify(data));
    });
  }

  build() {
    Column() {
      Text(this.message);
      Button('保存字符串数据：abcd').margin(5).onClick(() => {
        PreferencesManager.defManager.save("stringKey", "abcd");
      });

      Button('保存字符串数据：qwerdf').margin(5).onClick(() => {
        PreferencesManager.defManager.save("stringKey", "qwerdf");
      });

      Button('读取字符串数据').margin(5).onClick(() => {
        let stringValue = PreferencesManager.defManager.getStringValue("stringKey");
        this._toast('读取数据:\n' + stringValue);
      });

      Button('保存字符串数据：特殊字符').margin(5).onClick(() => {
        PreferencesManager.defManager.save("stringKey2", "~！@#￥%……&*（）——+？", true);
      });

      Button('读取特殊字符字符串').margin(5).onClick(() => {
        let stringValue = PreferencesManager.defManager.getStringValue("stringKey2", "取不到时设定的默认值", true);
        this._toast('读取数据:\n' + stringValue);
      });

      Button('保存数值数据：1234').margin(5).onClick(() => {
        PreferencesManager.defManager.save("numberKey", 1234);
      });

      Button('读取数值数据：1234').margin(5).onClick(() => {
        let numberValue = PreferencesManager.defManager.getNumberValue("numberKey");
        this._toast('读取数据:\n' + numberValue);
      });

      Button('保存布尔数据：true').margin(5).onClick(() => {
        PreferencesManager.defManager.save("boolKey", true);
      });

      Button('读取布尔数据：true').margin(5).onClick(() => {
        let value = PreferencesManager.defManager.getBoolValue("boolKey");
        this._toast('读取数据:\n' + value);
      });

      Button('保存数组数据').margin(5).onClick(() => {
        PreferencesManager.defManager.save("arrayKey", ['abc', '666', true, 123]);
      });

      Button('读取数组数据').margin(5).onClick(() => {
        let value = PreferencesManager.defManager.getArrayValue("arrayKey");
        this._toast('读取数据:\n' + value);
      });

      Button('保存 Map 数据 1').margin(5).onClick(() => {
        let map = new Map<string, Object>([
          ['mapKey1', 'mapValue'],
          ['mapKey2', 1234],
          ['mapKey3', false],
        ]);
        PreferencesManager.defManager.saveMapValue("mapKey", map);
      });

      Button('保存 Map 数据 2').margin(5).onClick(() => {
        let map = new Map<string, Object>([
          ['key', 'value'],
          ['number', 5678],
          ['bool', true],
        ]);
        PreferencesManager.defManager.saveMapValue("mapKey", map);
      });

      Button('读取 Map 数据').margin(5).onClick(() => {
        let value = PreferencesManager.defManager.getMapValue("mapKey");
        this._toast('读取数据:\n' + Utils.jsonStringify(value));
      });

    }
    .height('100%')
    .width('100%')
  }

  private _toast(msg: string) {
    promptAction.showToast({
      message: msg,
      duration: 3000
    });
  }
}