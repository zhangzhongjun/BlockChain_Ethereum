# ethereumjs-units项目

> 网址： https://github.com/ethereumjs/ethereumjs-units
> 

该项目用于实现以太币单位的相互转化

# 内部实现

index.js ：核心代码
units.json : 定义以太币单位名称和wei数量

```json
{
  "wei":          "1",
  "kwei":         "1000",
  "Kwei":         "1000",
  "babbage":      "1000",
  "femtoether":   "1000",
  "mwei":         "1000000",
  "Mwei":         "1000000",
  "lovelace":     "1000000",
  "picoether":    "1000000",
  "gwei":         "1000000000",
  "Gwei":         "1000000000",
  "shannon":      "1000000000",
  "nanoether":    "1000000000",
  "nano":         "1000000000",
  "szabo":        "1000000000000",
  "microether":   "1000000000000",
  "micro":        "1000000000000",
  "finney":       "1000000000000000",
  "milliether":   "1000000000000000",
  "milli":        "1000000000000000",
  "ether":        "1000000000000000000",
  "eth":          "1000000000000000000",
  "kether":       "1000000000000000000000",
  "grand":        "1000000000000000000000",
  "mether":       "1000000000000000000000000",
  "gether":       "1000000000000000000000000000",
  "tether":       "1000000000000000000000000000000"
}
```

在index.js中，首先读入units.json中的数据，在convert函数中，首先转化为单位wei，然后在转化为to的单位

# 外部接口

提供两个外部接口：

1. convert(value, unitFrom, unitTo) - 在两个单位之间进行转化

2. lazyConvert(value, unitTo) - 这里的value是带单位的