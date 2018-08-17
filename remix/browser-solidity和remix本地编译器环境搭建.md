# 搭建本地编译环境

[browser-solidity](https://github.com/ethereum/browser-solidity) 和[remix](http://remix.ethereum.org)是在线的编译器，可以将solidity编写的智能合约编译为字节码文件

由于某些原因，broswer-solidity和remix比较慢，所以需要在本地搭建编译环境，在本地编译。

# 搭建browser-solidity

1. 将源代码下载到本地，并解压缩
```bash
git clone git@github.com:ethereum/browser-solidity.git
```

2. 打开index.html直接使用即可

# 搭建remix

> 参考文献 https://github.com/ethereum/remix-ide 的readme

## 方式一

```bash
git clone https://github.com/ethereum/remix-ide.git
cd remix-ide
npm install
# this will clone https://github.com/ethereum/remix for you and link it to remix-ide
npm run setupremix  
npm start
```


访问Remix：

http://127.0.0.1:8080

## 方式二

```bash
npm install remix-ide -g
remix-ide
npm start
```

访问Remix：

http://127.0.0.1:8080
