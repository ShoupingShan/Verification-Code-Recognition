【本次整理完成的工作】
  1. 提取图片特征并整理成文件夹
  2. 修复.jpg.jpg双重命名的图片
  3. 修复或删除近200张标记错误的图片

基于对CAPTCHA的理解，验证码的本意是区分人类和机器，所以对人类都无法识别的图片进行分类是无意义的

【文件夹名称含义解析】
第一个标记字符：4 5 6
  4  图片内有四个字符
  5  图片内有五个字符
  6  图片内有六个字符

第二个标记字符：s n
  s  单一色彩（是待识别字符的颜色，不考虑背景颜色）
  n  彩色、非单一色彩

第三个标记字符：x n
  x  字符存在旋转和重叠，散乱排布
  n  字符不存在旋转和重叠，整齐排列

第四个标记字符：g n
  g  存在干扰（指前景的长横线，不包括背景的短线和噪声点等）
  n  不存在干扰

第五个标记字符：q n
  q  字符存在扭曲
  n  没有扭曲

第六个以后的标记字符：
  A  表示包含大写字母
  a  表示包含小写字母
  123  表示包含数字
