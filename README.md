# 奥集能平台前端

![Image text](https://user-images.githubusercontent.com/8328012/201800690-9f5e989e-4ed3-4817-85b9-b594ac89fd31.png)

## 架构简介

面向下一代互联网发展趋势，基于动态演化的复杂系统多主体建模方法，以所有权作为第一优先级，运用零信任安全机制，按自组织分形理念提炼和抽象“沟通、办事、门户、数据、关系”等基础功能，为 b 端和 c 端融合的全场景业务的提供新一代分布式应用架构。

## 基本功能

### 奥集能

奥集能（Orginone 发音[ˈɔːdʒɪnʌn]）个人和组织数字化一站式解决方案！  
奥：奥妙，莫名其妙。集，聚集，无中生有。能，赋能，点石成金。

### 门户

按权限自定义工作台、动态信息，新闻资讯，交易商城，监控大屏，驾驶舱等各类页面。以用户为中心，汇聚各类数据和信息。

### 沟通

为个人和组织提供可靠、安全、私密的即时沟通工具，好友会话隐私保护作为第一优先级，同事和组织等工作会话单位数据权利归属优先。

### 办事

满足个人、组织和跨组织协同办事需求，适应各类业务流程场景，支持发起、待办、已办、抄送、归档等不同状态流程类业务审核审批和查询。

### 数据

用户对数据标准和存储方式拥有绝对控制权，自主选择存储资源，自定义数据标准、业务模型和管理流程，无代码配置应用，便捷迁移外部数据，支持通用文件系统管理功能。

### 关系

支持个人和组织的关系的建立，好友和成员的管理，家庭、群组、单位、部门、集团等各类组织形态的构建，快速将工作和业务关系数字化、在线化，支持灵活的权限、角色和岗位管理等不同颗粒度的访问控制功能。

### 本存储是奥集能的前端 flutter 实现。

- 体验地址：https://ocia.orginone.cn 登录页扫码可以下载移动端
- 注册账号后可以申请加入一起研究群：research，协同研发群：asset_devops

# 项目目录

```
├── assets                              // 静态资源
├── android                             // android 原生实现
├── ios                                 // ios 原生实现
├── web                                 // web 原生实现
├── linux                               // linux 原生实现
├── macos                               // macos 原生实现
├── windows                             // windows 原生实现
└── lib                                 // flutter 实现
    ├── config                          // 配置
    ├── components                      // 项目组件
    ├── dart                            // 前端内核数据层代码
    ├── pages                           // 页面模块目录 UI层
        ├── chat                        // 沟通
        ├── home                        // 门户
        ├── login                       // 登录
        ├── setting                     // 关系
        ├── store                       // 数据
        └── work                        // 办事
    ├── utils                           // 工具库
    ├── channel                         // 钱包频道
    ├── common                          // 第三方通用服务
    ├── env.dart                        // 环境参数
    ├── main.dart                       // 主入口
    ├── global.dart                     // 入口初始化共用逻辑
    ├── main_dev.dart                   // 测试环境入口初始化处理
    └── main_prod.dart                  // 正式环境环境入口初始化处理
├── .gitignore                          // 忽视文件
├── .metadata                           // 元数据
├── pubspec.yaml                        // 包依赖配置
├── pubspec.lock                        // 包依赖配置版本锁定目录
├── test                                // 单元测试目录
├── README.md                           // 奥技能项目介绍
├── build                               // 构建打包生成目录
├── build_apk_dev.sh                    // 测试环境打包可执行脚本文件
├── build_apk_prod.sh                   // 正式环境打包可执行脚本文件
├── auto
└── analysis_options.yaml
```

### git 规范

1. 命名要求：
   1.1 统一前缀-姓名缩写-描述及日期。如 增加 XX 功能 `feature-lw-addmain1101`
   1.2 分支名称前缀如下

- common：调整通用组件、通用功能、通用数据接口、通用样式等
- feature：新功能
- fix：bug 修复
- hotfix：线上紧急修复
- perf：性能优化
- other：配置信息调整等非上面 5 种的改动改动

1. 迭代要求：
   2.1 `main` 分支为主干，所有迭代基于此分支进行获取
   2.2 所有新功能迭代，问题修复等，需要进行发布，需要提交 `PR` 请求到 `main` 分支。
   2.3 待系统上线后会拉出 `test` ,后续迭代与 `ISSUE`中问题进行关联的模式

### 依赖环境

目前官方 Flutter 版本迭代较快，其中引用的一些库在新版本中并没有适配,，建议 Flutter 版本与以下相同，后期考虑兼容升级。

1. Flutter 3.10.0
2. Dart 3.0.0
3. DevTools 2.20.1
4. gradle plugin 7.1.2
5. gradle 7.3.3

Flutter 安装过程可以参考 [Flutter 中文开发者网站 - Flutter](https://flutter.cn/docs)

### 参与贡献

1. fork 项目
   1. 首先，找到 fork 按钮，点击以后，你的存储内就会出现一个一模一样的项目。
2. 项目开发
   1. 按照奥集能项目的编码规则，对代码进行开发。
3. 跟上主项目的步伐
   1. 在你开发的过程中，主项目的代码也可能在更新。此时就需要你同步主项目的代码，找到 **Pull request** 按钮，点击。
   2. 在左侧选择你的存储的项目，右侧为主项目，此时你能在下面看到两个项目的区别，**点击 create pull request 按钮。**
   3. 填写 title，**点击 create pull request 按钮。**
   4. 进入 pull request 页面，拉到最下面，**点击 Merge pull request 按钮并确认，**现在你和主项目的代码就是同步的了。
4. Pull request
   1. 当你觉得你的代码开发完成，可以推送时，在确保你的修改全部推送到了你的存储的项目中，然后进入你的存储的项目页面，**点击 New pull request 按钮**，
   2. 然后**点击 create pull request 按钮**进行代码提交。
5. 审核
   1. 待项目的开发者审批完成之后，就是贡献成功了。

## 开发组构成


### 贡献者 Contributor

- 要求：完成一次pr的提交和合并

### 提交者 Committer

- 要求： 完成至少5个pr的提交和合并，并得到mentor的邀请
- 权力：review和accept pr
- Committer列表：

### 维护者 maintainer

- 要求：能长期维护项目，并得到mentor的邀请
- 权力：合并pr进入主分支
- Maintainer列表： [Captain842](https://github.com/Captain842), [realVeerHdu](https://github.com/realVeerHdu)

### 导师 Mentor

- 权力：决定项目发展方向，对项目进行指导
- 导师[panzhaohui](https://github.com/panzhaohui)
