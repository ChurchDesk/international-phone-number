# Author Marek Pietrucha
# https://github.com/mareczek/international-phone-number
((angular, factory) ->
  if typeof define is "function" and define.amd
    define "international-phone-number", [ "angular" ], (angular) ->
      factory angular

  else
    factory angular
) (if typeof angular is "undefined" then null else angular), (angular) ->
  "use strict"
  angular.module("internationalPhoneNumber", []).directive 'internationalPhoneNumber', () ->

    restrict:   'A'
    require: '^ngModel'
    scope: {
      ngModel: '='
      defaultCountry: '@'
    }

    link: (scope, element, attrs, ctrl) ->

      read = () ->
        ctrl.$setViewValue element.val()

      handleWhatsSupposedToBeAnArray = (value) ->
        if value instanceof Array
          value
        else
          value.toString().replace(/[ ]/g, '').split(',')

      options =
        autoFormat:         true
        autoHideDialCode:   true
        defaultCountry:     ''
        nationalMode:       false
        numberType:         ''
        onlyCountries:      undefined
        preferredCountries: ['us', 'gb']
        responsiveDropdown: false
        utilsScript:        ""

      angular.forEach options, (value, key) ->
        return unless attrs.hasOwnProperty(key) and angular.isDefined(attrs[key])
        option = attrs[key]
        if key == 'preferredCountries'
          options.preferredCountries = handleWhatsSupposedToBeAnArray option
        else if key == 'onlyCountries'
          options.onlyCountries = handleWhatsSupposedToBeAnArray option
        else if typeof(value) == "boolean"
          options[key] = (option == "true")
        else
          options[key] = option

      # Wait for ngModel to be set
      watchOnce = scope.$watch('ngModel', (newValue) ->
        # Wait to see if other scope variables were set at the same time
        scope.$$postDigest ->
          options.defaultCountry = scope.defaultCountry

          if newValue != null and newValue != undefined and newValue != ''
            element.val newValue

          element.intlTelInput(options)

          unless attrs.skipUtilScriptDownload != undefined || options.utilsScript
            element.intlTelInput('loadUtils', '/bower_components/intl-tel-input/lib/libphonenumber/build/utils.js')

          watchOnce()

      )



      ctrl.$parsers.push (value) ->
        return value if !value
        value.replace(/[^\d]/g, '')

      ctrl.$parsers.push (value) ->
        validity = true

        if value
          validity = element.intlTelInput("isValidNumber")
        else
          value = ''
          ctrl.$setPristine true;

        ctrl.$setValidity 'international-phone-number', validity
        #ctrl.$setValidity '', validity;
        value

      element.on 'blur keyup change', (event) ->
        scope.$apply read

      element.on '$destroy', () ->
        element.off 'blur keyup change'
