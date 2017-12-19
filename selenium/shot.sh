#!/usr/bin/env python

# -*- coding: utf-8 -*-

import os
from selenium import webdriver

# URL & File Name
URL = "https://www.baidu.com"
FILENAME = os.path.join(os.path.dirname(os.path.abspath(__file__)), "screen.png")

# Open Web Browser & Resize 720P
# driver = webdriver.Firefox()
driver = webdriver.Remote(
  command_executor="http://172.16.100.103:4444/wd/hub",
  desired_capabilities={
    "browserName": "chrome"
  })

#driver.implicitly_wait(30)
driver.set_window_size(1280, 720) 
driver.get(URL)

# Get Screen Shot
driver.save_screenshot(FILENAME)

# Close Web Browser
driver.quit()
