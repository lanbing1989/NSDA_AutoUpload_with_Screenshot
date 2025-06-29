# NSDA 自动上架助手（集成版：含每步自动截图）

本项目是一个基于 AutoIt 的自动化工具，**集成了 NSDA 软件自动上架流程 和 每步自动截图功能**，所有参数均可通过图形界面配置，并自动保存到 ini 文件，适合流程追溯和自动化批量操作。

---

## 功能特点

- 一键自动完成：刷新 → 全选 → 上架C5GAME → 一键定价 → 确认上架 → 失败确认 → 循环等待
- 每个操作步骤自动截图，图片以“步骤名+时间戳”命名，保存路径可自由设置
- 所有操作坐标、截图目录均可通过 GUI 配置，并持久化保存到 `NSDA_Coords.ini`
- 支持鼠标拾取操作坐标，适配不同分辨率/布局
- 支持快捷键终止（Ctrl+Alt+Q）

---

## 使用说明

### 环境要求

- Windows 操作系统
- [AutoIt v3](https://www.autoitscript.com/site/autoit/downloads/) 环境

### 运行方法

1. 下载本项目所有 `.au3` 脚本文件（及自动生成的 ini 文件）
2. 用 AutoIt SciTE 编辑器 或 右键选择“使用AutoIt运行脚本”启动该脚本
3. 按界面提示配置各项参数，点击“开始”即可自动运行

### 参数配置

- **坐标拾取**：点击“拾取”按钮，鼠标移动到目标位置，按 F9 锁定当前坐标
- **截图保存目录**：点击“浏览”按钮，选择图片保存目录
- **参数持久化**：所有设置自动保存到 `NSDA_Coords.ini`，重启程序后自动加载

---

## 文件结构

```text
NSDA_AutoUpload_with_Screenshot.au3   # 自动上架+每步截图主程序
NSDA_AutoUpload_with_Screenshot.exe   # 无需运行环境，可直接在windows上运行。
NSDA_Coords.ini                       # 参数配置文件（自动生成/保存）
README.md                             # 项目说明文档
```

---

## 注意事项

- 脚本模拟鼠标点击，运行期间请勿干扰鼠标/键盘
- 坐标设置需准确，建议在高分辨率下拾取
- 如 NSDA 软件未启动，脚本自动提示并中止
- 截图目录需有写入权限

---

## 尚未解决的问题

- 由于全选按钮，会左右变动，根据右侧的数字变化，例如1、10、100，目前只能选中两位数和三位数，一位数的无法选中。

---

## 联系方式

如有问题或建议，欢迎联系：
- 灯火通明（济宁）网络有限公司
- 作者：lanbing1989

---

## 版权声明

版权所有 © 灯火通明（济宁）网络有限公司  
仅供学习与内部使用，严禁商业传播。