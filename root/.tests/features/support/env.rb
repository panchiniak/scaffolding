#encoding: utf-8

BASE_URL = ENV['BASE_URL']
HIPCHAT_TOKEN = ENV['HIPCHAT_TOKEN']
HIPCHAT_ROOM = ENV['HIPCHAT_ROOM']
HTML_RESULTS_URL = ENV['HTML_RESULTS_URL']
PROJECT_NAME = ENV['PROJECT_NAME']
LEAVE_BROWSER_OPENED = ENV['LEAVE_BROWSER_OPENED']
GENERATE_MP4 = ENV['GENERATE_MP4']
FULL_SCREEN = ENV['FULL_SCREEN']
PROJECTS_BASE_URL = ENV['PROJECTS_BASE_URL']
SUB_SHOT = ENV['SUB_SHOT']
SEND_MAIL = ENV['SEND_MAIL']

HALL_TOKEN = ENV['HALL_TOKEN']
HALL_ROOM = ENV['HALL_ROOM']

require 'cucumber/formatter/unicode'
require 'watir-webdriver'
require 'page-object'
require 'page-object/page_factory'
require 'hipchat-api'

# @todo: handling of possible errors from sync
if ENV['CUCUMBER_SYNC_SWITCH'] == 'true'
  puts 'Running features syncronization...'
  sync_result = `cd inc; perl -f sync.pl;`
end

unless HIPCHAT_ROOM.nil? ||
  hipchat_api = HipChat::API.new(HIPCHAT_TOKEN)
end


$: << File.dirname(__FILE__)+'/../../lib'

require 'pages.rb'

if ENV['HEADLESS'] == 'true'
  require 'headless'
  #headless = Headless.new(display: 100, dimensions: '800x600x24')
  # @TODO: create a safe guard lock for the id of xvfb below.
  # random_xvfb_id = Random.new.rand(0000..9999)
  random_xvfb_id = Random.new.rand(00000000..99999999)
  headless = Headless.new(display: random_xvfb_id, dimensions: '1280x1024x24')

  if ENV['GENERATE_MP4'] == 'true'
    headless.video.start_capture
  end

  if headless.start
    puts "Headless mode: ON."
  end
  at_exit do

    if ENV['GENERATE_MP4'] == 'true'
      headless.video.stop_and_save("../tests/projects/#{PROJECT_NAME}/results/tT-#{PROJECT_NAME}.mov")
      `avconv -loglevel quiet -y -i ../tests/projects/#{PROJECT_NAME}/results/tT-#{PROJECT_NAME}.mov -c:v libx264 ../tests/projects/#{PROJECT_NAME}/results/tT-#{PROJECT_NAME}.mp4; rm -f ../tests/projects/#{PROJECT_NAME}/results/tT-#{PROJECT_NAME}.mov`
      unless HIPCHAT_ROOM.nil? ||
        hipchat_api.rooms_message(HIPCHAT_ROOM, 'Padumts', "Agora tambem em <a href='http://panchiniak.toetec.com.br/testa/tests/projects/#{PROJECT_NAME}/results/tT-#{PROJECT_NAME}.mp4'>Video</a>", notify = 0, color = 'yellow', message_format = 'html')
      end

    end

    headless.destroy

  end
end

World PageObject::PageFactory

driver = (ENV['WEB_DRIVER'] || :firefox).to_sym
client = Selenium::WebDriver::Remote::Http::Default.new
client.timeout = 180

browser = Watir::Browser.new driver, :http_client => client

browser.window.resize_to(1280,1024)

if ENV['FULL_SCREEN'] == 'true'
  browser.element.send_keys [:f11]
end

start_test_time = Time.now

unless HIPCHAT_ROOM.nil? ||
  if (ENV['SUB_SHOT']) != 'true'
    hipchat_api.rooms_message(HIPCHAT_ROOM, 'Padumts', '<img border="0" src="http://toetec.com.br/sites/default/files/ico-5.jpg" alt="ico" width="40" height="50"> Disparando bateria de testes contra <a href="' +  BASE_URL + '">' + PROJECT_NAME + '</a>...', notify = 0, color = 'yellow', message_format = 'html')
  end
end

unless HALL_ROOM.nil? ||
  if (ENV['SUB_SHOT']) != 'true'
    # puts 'entrou no hall Disparando bateria'
    ENV['PADUMTS_HALL_MESSAGE'] = 'Disparando bateria de testes contra <a href="' +  BASE_URL + '">' + PROJECT_NAME + '</a>...'
    hall_result = `cd inc/hallert; ./hallert -t ${HALL_ROOM} -m "${PADUMTS_HALL_MESSAGE}" -s Padumts`

    # puts 'variável do ambiente:' + ENV['PADUMTS_HALL_MESSAGE']
    # puts 'output do hallert:' + hall_result
  end
end


# hipchat_api.rooms_message(HIPCHAT_ROOM, 'Padumts', '<img border="0" src="http://toetec.com.br/sites/default/files/ico-5.jpg" alt="ico" width="40" height="50"> Iniciando bateria de testes...', notify = 0, color = 'yellow', message_format = 'html')

Dir::mkdir('../tests/projects/' + PROJECT_NAME + '/results') if not File.directory?('../tests/projects/' + PROJECT_NAME + '/results')

Before {
  @browser = browser
}


After do |scenario|

  Dir::mkdir('../tests/projects/' + PROJECT_NAME + '/results/screenshots') if not File.directory?('../tests/projects/' + PROJECT_NAME + '/results/screenshots')

  #@todo: existe um bug aqui, as imagens não estão aparecendo
  def screenshot_name screenshot_type, scenario_name
    screenshot = "../tests/projects/" + PROJECT_NAME + "/results/screenshots/" + screenshot_type + "_#{scenario_name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"

    #screenshot = "../tests/projects/" + PROJECT_NAME + "/results/" + screenshot_type + "_#{scenario_name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"

    @browser.driver.save_screenshot(screenshot)
    #embed screenshot, 'image/png'

    #embed "http://t.toetec.com.br/sites/default/files/testa/tests/projects/" + PROJECT_NAME + "/results/screenshots/" + screenshot_type + "_#{scenario_name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png", 'image/png'
    if (PROJECTS_BASE_URL)
      embed PROJECTS_BASE_URL + PROJECT_NAME + "/results/screenshots/" + screenshot_type + "_#{scenario_name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png", 'image/png'
    end

    return screenshot
  end


  if scenario.failed?
    screenshot = screenshot_name("FAILLED", scenario.name)
    #@todo: Rewrite bellow into a function
    unless HIPCHAT_ROOM.nil? ||
      hipchat_api.rooms_message(HIPCHAT_ROOM, 'Padumts', 'Notas de teste: cenário reprovado em ' + scenario.name, notify = 0, color = 'red', message_format = 'html')
    end

    ENV['PADUMTS_HALL_MESSAGE'] = 'Notas de teste: cenário reprovado em ' + scenario.name + '.'
    hall_result = `cd inc/hallert; ./hallert -t ${HALL_ROOM} -m "${PADUMTS_HALL_MESSAGE}" -s Padumts`

  end

  if ENV['FULLSHOT'] == 'true'
    if scenario.passed?
      screenshot = screenshot_name("PASSED", scenario.name)
      #@todo: Rewrite bellow into a function
      #hipchat_api.rooms_message(HIPCHAT_ROOM, 'Cucumber', 'Notas de teste: cenário aprovado em ' + scenario.name, notify = 0, color = 'green', message_format = 'html')
    end
  end
end

at_exit {
  end_test_time = Time.now
  overall_test_time = end_test_time - start_test_time

  random = Random.new.rand(00000000..99999999)
  random_string = '?nocache=' + random.inspect

  unless HIPCHAT_ROOM.nil? ||
    if (ENV['SUB_SHOT']) != 'true'
        hipchat_api.rooms_message(HIPCHAT_ROOM, 'Padumts', 'Bateria concluída em <b>' + (overall_test_time).round(2).inspect + '</b> segundos. Veja o <a href="'+ HTML_RESULTS_URL + random_string + '">Resultado Completo</a>.', notify = 0, color = 'yellow', message_format = 'html')
    end
  end

  unless HALL_ROOM.nil? ||
    if (ENV['SUB_SHOT']) != 'true'
      ENV['PADUMTS_HALL_MESSAGE'] = 'Bateria concluída em <b>' + (overall_test_time).round(2).inspect + '</b> segundos. Veja o <a href="'+ HTML_RESULTS_URL + random_string + '">Resultado Completo</a>.'
      hall_result = `cd inc/hallert; ./hallert -t ${HALL_ROOM} -m "${PADUMTS_HALL_MESSAGE}" -s Padumts`

    end
  end

  unless SEND_MAIL.nil? ||
    if (ENV['SUB_SHOT']) != 'true'
      puts "Mandando email de alerta para: " + SEND_MAIL

      #@TODO: provavelmente esta variável de ambiente irá se chocar com outro disparo simultâneo
      ENV['OVERALL_TEST_TIME'] = (overall_test_time).round(2).inspect

      email_result = `cd inc/pmail; python pmail.py ${SEND_MAIL} ${OVERALL_TEST_TIME} ${PROJECT_NAME};`
      puts email_result

    end
  end

  if ENV['LEAVE_BROWSER_OPENED'] != 'true'
    browser.close
  end

}
