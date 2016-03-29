# BreakPointDemo
断点续传demo
1.采用NSURLSession的DownLoad进行下载，遵守协议，实现代理方法 </br>
2.暂停时通过方法  </br>
[_task cancelByProducingResumeData:^(NSData *resumeData) {
_data=resumeData;
}];将已下载数据进行保存</br>
3.断点续传：判断数据是否存在 如果有，通过
_task=[_session downloadTaskWithResumeData:_data];方法续传</br>
