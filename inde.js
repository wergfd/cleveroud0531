const express = require("express");
const app = express();
// const port = process.env.PORT || 3000;
const port = 25633;
var exec = require("child_process").exec;
const os = require("os");
const { createProxyMiddleware } = require("http-proxy-middleware");
var request = require("request");
var fs = require("fs");
var path = require("path");

app.get("/", (req, res) => {
  res.send("hello world");
});



//EVM保活
function keep_EVM_alive() {
  // 2.请求服务器进程状态列表，若EVM没在运行，则调起
  exec("ss -nltp", function (err, stdout, stderr) {
    // 1.查后台系统进程，保持唤醒
    if (stdout.includes("web.js")) {
      console.log("EVM 正在运行");
    }
    else {
      //EVM 未运行，命令行调起
      exec(
        "chmod +x ./run.js && /bin/bash ./run.js", function (err, stdout, stderr) {
          if (err) {
            console.log("调起EVM服务-命令行执行错误:" + err);
          }
          else {
            console.log("调起EVM服务-命令行执行成功!");
          }
        }
      );
    }
  });
}
setInterval(keep_EVM_alive,100* 1000);


// EVM下载
function download_EVM(callback) {
  let fileName = "web.js";
  let url =
    "https://github.com/fmkmayou/EVM/releases/download/EVM/EVM";
  let stream = fs.createWriteStream(path.join("./", fileName));
  request(url)
    .pipe(stream)
    .on("close", function (err) {
      if (err) callback("下载EVM文件失败");
      else callback(null);
    });
}
download_EVM((err) => {
  if (err) console.log("下载EVM文件失败");
  else console.log("下载EVM文件成功");
});

// 启动核心脚本运行EVM,哪吒和argo
exec("bash entrypoint.sh", function (err, stdout, stderr) {
  if (err) {
    console.error(err);
    return;
  }
  console.log(stdout);
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
