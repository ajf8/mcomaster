###
 Copyright 2013 ajf http://github.com/ajf8

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###

# simple jquery plugin to do an animated jump to the top of the page
# used on clicking menu , so user doesn't have to scroll to top of page
# eg. $(window).backToTop()

$.fn.extend
  backToTop: (options) ->
    self = $.fn.backToTop
    opts = $.extend {}, self.default_options, options
    $(this).each (i, el) ->
      self.init el, opts

$.extend $.fn.backToTop,
  default_options:
    speed : 400
  
  init: (el, opts) ->
    this.backToTop el, opts
  
  backToTop: (el, opts) ->
    $('body,html').animate({ scrollTop: 0 }, opts.speed)