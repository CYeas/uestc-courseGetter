require 'mechanize'
require 'watir'
require 'headless'
class Spider

  def getStdCourseInfo(username, password)
    agent = login(username, password)
    page = agent.get ('http://eams.uestc.edu.cn/eams/courseTableForStd.action')
    page = page.links.first.click if page.links.first.text == '点击此处'
    ids = parserIds page.body
    return if ids.nil?
    page = agent.post('http://eams.uestc.edu.cn/eams/courseTableForStd!courseTable.action', {'ignoreHead' => '1', 'setting.kind' => 'std', 'startWeek' => '1', 'semester.id' => '143', 'ids' => ids})
    courseInfos = parserCourse page.body
    File.open("./#{username}.txt", 'w') do |file|
      courseInfos.each do |item|
        file.puts(item.to_str)
      end
    end
  end

  def getAllcourse(username, password)
    # headless = Headless.new
    # headless.start
    browser = Watir::Browser.new
    url = 'portal.uestc.edu.cn'
    # begin
    browser.goto url
    browser.text_field(name: 'username').set username
    browser.text_field(name: 'password').set password
    browser.button(type:'submit').click
    browser.goto 'http://eams.uestc.edu.cn/eams/home!childmenus.action'
    browser.as.first.click if browser.as.length >= 1 && browser.as.first.text.eql?('点击此处')
    clickByText(browser, '全校开课查询')
    sleep 5
    File.open("./allCourse.txt", 'w') do |file|
      while true
        browser.trs(:class => 'griddata-even').each do |tr|
          allCourseTrParser(tr.html, file)
        end
        browser.trs(:class => 'griddata-odd').each do |tr|
          allCourseTrParser(tr.html, file)
        end
        flag = clickByText(browser, '后页›')
        break unless flag
      end
    end
    # ensure
    # headless.destroy
    # end
  end

  private
  def allCourseTrParser tr, file
    tr.scan(/<td>.*?<\/td>/m) do |item|
      file.print item.gsub(/\s/, '').gsub(/<td>/, '').gsub(/<\/td>/, ';').gsub(/<.*>/, '')
    end
    file.print "\n"
  end

  private
  def login(username, password)
    agent = Mechanize.new
    page = agent.get 'http://portal.uestc.edu.cn'
    login = page.forms.first
    login.username = username
    login.password = password
    agent.submit(login, login.buttons.first)
    agent
  end

  private
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

  private
  def parserCourse(content)
    content.force_encoding('UTF-8')
    content = content.scan(/TaskActivity\(\".*table0\.marshalTable/m)
    content = content[0].split('new')
    results = []
    content.map do |block|
      courseInfo = Course.new
      courseInfo.coursePosition = Array.new
      courseInfo.basic = block.scan(/\(.*\)/)[0]
      block.scan(/index\s?=.*/) do |indexLine|
        data = indexLine.scan(/\d/)
        courseInfo.coursePosition.push(data)
      end
      results.push(courseInfo)
    end
    results
  end

  private
  def clickByText(browser, text)
    browser.links.each do |link|
      if link.html.include? text
        link.click
        return true
      end
    end
    false
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
