import 'dart:io';

void main() async {
  final inputFile = File('docs/Data.md');
  final outputFile = File('assets/data/jobs.json');

  if (!await inputFile.exists()) {
    print('❌ Data.md文件不存在');
    return;
  }

  // 读取文件内容
  final lines = await inputFile.readAsLines();

  if (lines.isEmpty) {
    print('❌ Data.md文件为空');
    return;
  }

  // 第一行是表头
  final headers = lines[0].split('\t');

  // 解析数据行
  final List<Map<String, String>> jobs = [];

  for (int i = 1; i < lines.length; i++) {
    final values = lines[i].split('\t');
    if (values.length != headers.length) {
      print('⚠️  第${i + 1}行数据格式不正确，跳过');
      continue;
    }

    final jobData = <String, String>{};
    for (int j = 0; j < headers.length; j++) {
      jobData[headers[j]] = values[j];
    }

    jobs.add(jobData);
  }

  // 创建JSON输出
  final jsonString = _formatJson(jobs);

  // 确保输出目录存在
  await Directory('assets/data').create(recursive: true);

  // 写入文件
  await outputFile.writeAsString(jsonString);

  print('✅ 成功转换${jobs.length}条岗位数据到jobs.json');
}

String _formatJson(List<Map<String, String>> jobs) {
  final buffer = StringBuffer();
  buffer.writeln('[');

  for (int i = 0; i < jobs.length; i++) {
    final job = jobs[i];
    buffer.write('  {');
    buffer.write('\n    "jobName": "${_escapeJson(job['岗位名称'])}",');
    buffer.write('\n    "location": "${_escapeJson(job['地址'])}",');
    buffer.write('\n    "salaryRange": "${_escapeJson(job['薪资范围'])}",');
    buffer.write('\n    "companyName": "${_escapeJson(job['公司名称'])}",');
    buffer.write('\n    "industry": "${_escapeJson(job['所属行业'])}",');
    buffer.write('\n    "companySize": "${_escapeJson(job['公司规模'])}",');
    buffer.write('\n    "companyType": "${_escapeJson(job['公司类型'])}",');
    buffer.write('\n    "jobCode": "${_escapeJson(job['岗位编码'])}",');
    buffer.write('\n    "jobDetails": "${_escapeJson(job['岗位详情'])}",');
    buffer.write('\n    "updateDate": "${_escapeJson(job['更新日期'])}",');
    buffer.write('\n    "companyDetails": "${_escapeJson(job['公司详情'])}",');
    buffer.write('\n    "sourceUrl": "${_escapeJson(job['岗位来源地址'])}"');
    buffer.write('\n  }');

    if (i < jobs.length - 1) {
      buffer.write(',');
    }
    buffer.write('\n');
  }

  buffer.writeln(']');
  return buffer.toString();
}

String _escapeJson(String? value) {
  if (value == null) return '';
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}
