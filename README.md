# uestc-courseGetter
获取uestc用户的课程表信息

使用方法

```
bundle install
ruby main.rb <学号> <密码>
```

获得数据将存在`data/`中

####数据实例：
`("9384","王晓川","49469(I1213330.01)","孙子兵法与创新竞争(I1213330.01)","1280","品学楼C-230","01111111111111111100000000000000000000000000000000000");3,8;3,9;3,1;`

####字段解释
从左往右
1. 教师编号

2. 教师名字

3. 课程编号

4. 课程名称

5. 教室编号

6. 教室

7. 上课周数，第n位代表第n周是否有课，1为有，0为没有

8. 课程时间，每组两个数，组用分号隔开，每组第一个代表星期（从0开始算），第二位代表第几节课（从0开始）

   如实例中第一组为3，8，表示星期四（3+1）的第9节课（8+1），第二组为3，9星期四第10节课，etc