# frozen_string_literal: true

module Constants
  module FolderPath
    FOLDER_TMP = File.expand_path('../../../tmp', __dir__)
    FOLDER_USER_DOWNLOAD = File.expand_path('../../../download', __dir__)
    FOLDER_TMP_DOWNLOAD = File.expand_path('../../../tmp_download', __dir__)
    FOLDER_TMP_GUID = File.expand_path('../../../tmp_pre_process', __dir__)
    FOLDER_INSIDE = '/folder_1'
    FOLDER_OUTSIDE = '/folder_2'
  end
  module ModemStatus
    STATUS_MODEM_OK = "OK";
    STATUS_MODEM_READY = "READY";
    STATUS_MODEM_PIN = "SIM PIN";
    STATUS_MODEM_PUK = "SIM PUK";
    STATUS_MODEM_NOSIM = "NO SIM";
    STATUS_MODEM_ERROR = "ERROR";
  end

  module CommandPort
    COMMAND_CONNECT = "AT\r";
    COMMAND_RESET_0 = "AT+CFUN=0\r";
    COMMAND_RESET_1 = "AT+CFUN=1\r";
    COMMAND_STATUS = "AT+CPIN?\r";
    COMMAND_BALANCE = "AT+CUSD=1,\"*101#\",15\r";
    COMMAND_PHONE = "AT+CNUM\r";
    #Send money sim Sigapo
    COMMAND_TRANSFER = "AT+CUSD=1,\"*136*{0}*{1}*{2}#\",15\r";
    COMMAND_ACTIVE = "AT+CUSD=1,\"*000*1#\",15\r";
    #Use message format "Text mode"
    COMMAND_SET_MESSAGES_FORMAT_TEXT = "AT+CMGF=1\r";
    #Use character set GSM
    COMMAND_SET_MESSAGES_CHARACTER = "AT+CSCS=\"GSM\"\r";
    #Use Encoding
    COMMAND_SET_MESSAGES_ENCODING = "AT+CSMP=17,167,2,0\r";
    #Select SIM storage
    COMMAND_SET_SELECT_SIM_STORAGE = "AT+CPMS=\"SM\"\r";
    #Get list messages in sim
    COMMAND_GET_LIST_MESSAGES = "AT+CMGL=\"ALL\"\r";
    #Change pass send money 0: current pass, 1: New pass
    COMMAND_CHNAGE_PASS = "AT+CUSD=1,\"*000*{0}*{1}#\",15\r";
    #Delete messages
    COMMAND_DELETE_MESSAGES = "AT+CMGD={0}\r";
    #Send messages
    COMMAND_SEND_MESSAGES = "AT+CMGS=\"{0}\"\r";
  end


  module MaxLength
    EMAIL_MAX_LENGTH = 128
    NAME_MAX_LENGTH = 128
  end

  class << self
    Constants.constants.each do |module_name|
      sub_module = Constants.const_get(module_name)
      next unless sub_module.is_a?(Module)

      define_method(module_name.to_s + 'Values') do
        sub_module.constants.map do |const_name|
          sub_module.const_get(const_name)
        end
      end
    end
  end
end
