## Quick-cocos和cocos2d-x的区别 ##

* cocos2d-x：目前基于 cocos2d-x 2.1.4 版本
* tolua++：用于将 C++ 接口导出给 Lua 脚本使用
* LuaJIT：最快的 Lua 虚拟机
* cocos2d-x-extra：扩展功能，包括数据加密编码、网络传输、设备功能访问等
* Chipmunk 2D：物理引擎，以及相应的 cocos2d-x 和 Lua 封装接口
* CSArmature：一个骨骼动画播放库，支持 DragonBones 和 CocoStudio 创建的骨骼动画

#####除此之外，还包含一些 Lua 的扩展：

* lua_extensions：一些必备的 Lua 模块，包括 JSON、ZLib、LuaFileSystem、LuaSocket 等
* LuaJavaBridge：简单的 Lua - Java 交互接口，简化 SDK 集成
* LuaObjectiveCBridge：简单的 Lua - Objective-C 交互接口
