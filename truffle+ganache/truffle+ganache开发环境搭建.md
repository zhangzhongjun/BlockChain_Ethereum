> truffle是一个开发框架，而truffle是基于node js开发的
> ganache是一个以太坊客户端，用于搭建本地测试网络。
> 

# 以太坊环境搭建——linux



## 安装nodejs环境

```bash
git clone git@github.com:zhangzhongjun/EthLearning.git
cd node
make
make install

node -v
npm -v
```

## 配置npm源

```bash
# 配置国内源
sudo npm config set registry http://registry.npm.taobao.org
```

## 安装truffle

```bash
npm install -g truffle
```

## 下载并安装ganache

ganache的前身是testRPC，是一种以太坊客户端。

命令行版本：
```bash
sudo npm install -g ganache-cli
```

GUI版本： https://github.com/trufflesuite/ganache/releases
```bash
wget https://github.com/trufflesuite/ganache/releases/download/v1.0.1/ganache-1.0.1-x86_64.AppImage  //下载ganache
chmod +x ganache-1.0.1-x86_64.AppImage //修改权限
sudo ./ganache-1.0.1-x86_64.AppImage //启动ganache
```

## 启动ganache

```bash
ganache-cli
```

# 以太坊环境搭建——windows

## 安装nodejs环境

1. 前往node.js官网下载并安装工具，这里安装路径选到D盘，D:\Program Files\nodejs安装完毕在命令行输入以下命令测试是否安装成功，正确会出现版本号
```bash
node -v
```

2. 配置npm的全局模块的存放路径以及cache的路径，例如我希望将以上两个文件夹放在NodeJS的主目录下，便在NodeJs下建立"node_global"及"node_cache"两个文件夹，输入以下命令改变npm配置
```bash
npm config set prefix "D:\Program Files\nodejs\node_global"
npm config set cache "D:\Program Files\nodejs\node_cache"
```

3. 在系统环境变量添加系统变量NODE_PATH，输入路径D:\ProgramFiles\nodejs\node_global\node_modules，此后所安装的模块都会安装到改路径下 

4. 在命令行输入以下命令试着安装express（注：“-g”这个参数意思是装到global目录下，也就是上面说设置的“D:\Program Files\nodejs\node_global”里面。）


```bash
npm install express -g
```
安装完毕后可以看到.\node_global\node_modules\express 已经有内容

5. 在命令行输入node进入编辑模式，输入以下代码测试是否能正常加载模块：

```bash
require('express')
```

## 安装cnpm

1. 安装包

```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

2. 因为cnpm会被安装到D:\Program Files\nodejs\node_global下，而系统变量path并未包含该路径。在系统变量path下添加该路径即可正常使用cnpm。

3. 输入cnpm -v输入是否正常

```bash
cnpm -v
```




# 一个例子

```bash
mkdir myproject
cd myproject/
truffle init
truffle compile
truffle migrate
```

# 官方自带的例子

## 下载项目
```bash
mkdir MetaCoin
cd MetaCoin
truffle unbox metacoin
```

## 修改配置文件

1. 如果是在windows下，则删除truffle.js
2. 如果是linux下，修改truffle.js为如下内容
```javascript
module.exports = {  
    networks: {  
        development: {  
            host: 'localhost',  
            port: '7545',  
            network_id: '*' // Match any network id  
        }  
    }  
};  
```
3. 如果是windows下，修改truffle-config.js为如下内容

```javascript
module.exports = {  
    networks: {  
        development: {  
            host: 'localhost',  
            port: '7545',  
            network_id: '*' // Match any network id  
        }  
    }  
}; 
```

## 编译
```bash
truffle compile
```

## 部署
```bash
truffle migrate
```

