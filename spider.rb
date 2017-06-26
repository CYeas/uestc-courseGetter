require 'mechanize'
class Spider

  def getInfo(username, password)
    agent = Mechanize.new
    page = agent.get 'http://portal.uestc.edu.cn'
    login = page.forms.first
    login.username = username
    login.password = password
    agent.submit(login, login.buttons.first)
    page = agent.get('http://eams.uestc.edu.cn/eams/courseTableForStd.action')
    page = page.links.first.click if page.links.first.text == '点击此处'
    ids = parserIds page.body
    return if ids.nil?
    page = agent.post 'http://eams.uestc.edu.cn/eams/courseTableForStd!courseTable.action', {'ignoreHead' => '1', 'setting.kind' => 'std', 'startWeek' => '1', 'semester.id' => '143', 'ids' => ids}
    courseInfos = parserCourse page.body
    File.open("./#{username}.txt", 'w') do |file|
      courseInfos.each do |item|
        file.puts(item.to_str)
      end
    end
  end

  def parserIds(content)
    begin
      content.force_encoding 'UTF-8'
      result = content.scan /ids.*\"/
      result = result[0]
      result.split("\"").last
    rescue
      puts '密码或用户名错误'
      nil
    end
  end

  def parserCourse(content)
    content.force_encoding 'UTF-8'
    content = content.scan /TaskActivity\(\".*table0\.marshalTable/m
    content = content[0].split('new')
    results = []
    content.map do |block|
      courseInfo = Course.new
      courseInfo.coursePosition = Array.new
      courseInfo.basic = block.scan(/\(.*\)/)[0]
      block.scan /index\s?=.*/ do |indexLine|
        data = indexLine.scan /\d/
        courseInfo.coursePosition.push data
      end
      results.push courseInfo
    end
    results
  end

  class Course
    @basic = ''
    @coursePosition = []
    attr_accessor :basic, :coursePosition
    def to_str
      str = self.basic + ';'
      self.coursePosition.each do |item|
        str += "#{item[0]},#{item[1]};"
      end
      str
    end
  end
end
