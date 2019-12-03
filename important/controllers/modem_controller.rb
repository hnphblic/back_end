# frozen_string_literal: true

require 'pry'
require 'uri'
require 'serialport'

# Control File action
class ModemController < ApplicationController
  
  before do
     unless authorized_admin?
      access_denied
    end
    convert_params
  end

 # Create modem
  get '/load_modem' do
    begin
        baud_rate = 11500
        data_bits = 8
        stop_bits = 1
        parity = SerialPort::NONE
        ports = []
        modems =[]
        1.upto 64 do |index|
          begin
            portname = 'COM' + index.to_s
            serial = SerialPort.new(portname, baud_rate, data_bits, stop_bits, parity) 
            ports << portname if serial
            serial.close
          rescue  Exception => e
            ports << portname if e.to_s.include? "ACCESS_DENIED"
          end
        end
        ports.each do |c|
          modem = Modem.where(name: c).first
          if !modem
            modem = Modem.new(
              name: c,
              index: 0,
              status: Constants::ModemStatus::STATUS_MODEM_OK,
              current_bank: 0,
              create_date: Time.now,
              Note: '',
            )
            unless modem.save
              result = helper_render_message(
                400,
                I18n.t('modem_controller.errors.cannot_create_modem'),
                modem.errors.messages,
              )
              halt result[:status], result[:response].to_json
            end
          end
          modems << modem
        end
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
          list_modem: modems,
        )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  post '/check_modem', needs: %i[portname] do
    begin
        mode = check_status(params[:portname])
        if (mode.status == Constants::ModemStatus::STATUS_MODEM_READY)
            mode = Modem.update(
              status: Constants::ModemStatus::STATUS_MODEM_READY,
            )
            unless mode.save
              result = helper_render_message(
                400,
                I18n.t('modem_controller.errors.cannot_update_modem'),
                modem.errors.messages,
              )
              halt result[:status], result[:response].to_json
            end
        else
            reset_modem(params[:portname]);
            sleep(3);
            mode = check_status(params[:portname])
            if (mode.status == Constants::ModemStatus::STATUS_MODEM_READY)
                mode = Modem.update(
                  status: Constants::ModemStatus::STATUS_MODEM_READY,
                )
                unless mode.save
                  result = helper_render_message(
                    400,
                    I18n.t('modem_controller.errors.cannot_update_modem'),
                    modem.errors.messages,
                  )
                  halt result[:status], result[:response].to_json
                end
            end
        end
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
          modem: mode,
        )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  get '/load_phone', needs: %i[list_modem]do
    begin
        list_modem.each do |modem|
            if (modem.status == Constants::ModemStatus::STATUS_MODEM_READY)
               return true
            end
        end

        baud_rate = 11500
        data_bits = 8
        stop_bits = 1
        parity = SerialPort::NONE
        ports = []
        modems =[]
        1.upto 64 do |index|
          begin
            portname = 'COM' + index.to_s
            serial = SerialPort.new(portname, baud_rate, data_bits, stop_bits, parity) 
            ports << portname if serial
            serial.close
          rescue  Exception => e
            ports << portname if e.to_s.include? "ACCESS_DENIED"
          end
        end
        ports.each do |c|
          modem = Modem.where(name: c).first
          if !modem
            modem = Modem.new(
              name: c,
              index: 0,
              status: Constants::ModemStatus::STATUS_MODEM_OK,
              current_bank: 0,
              create_date: Time.now,
              Note: '',
            )
            unless modem.save
              result = helper_render_message(
                400,
                I18n.t('modem_controller.errors.cannot_create_modem'),
                modem.errors.messages,
              )
              halt result[:status], result[:response].to_json
            end
          end
          modems << modem
        end
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
          list_modem: modems,
        )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Create modem
  post '/create_modem', needs: %i[name] do
    begin
        modem = Modem.new(
          name: params[:name],
          index: 0,
          status: '',
        )
        unless modem.save
           result = helper_render_message(
          400,
          I18n.t('modem_controller.errors.cannot_create_modem'),
          user.errors.messages,
        )
        halt result[:status], result[:response].to_json
        end
        list_id << modem.id
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        list_id: list_id,
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Using to delete modem
  # Input:  array: list_modem
  # Output: return message success when done, error when fail
  post '/delete_modem', needs: %i[list_modem] do
    begin
      list_modem_id = params[:list_modem].map(&:to_i)
      file_errors = ''
      ActiveRecord::Base.transaction do
        list_modem.each do |modem|
            md = Modem.where(id: modem[:id]).first
            md.destroy
        end
      end
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  private

  def check_status(portname)
    begin
        baud_rate = 11500
        data_bits = 8
        stop_bits = 1
        parity = SerialPort::NONE
        portname = portname
        serial = SerialPort.new(portname, baud_rate, data_bits, stop_bits, parity)
        serial.read_timeout = 100
        serial.write(Constants::CommandPort::COMMAND_STATUS)
        ss = "";
        i = 0;
        isReading = true;
        
        while isReading do
            if (i == 10)
                break;
            end
            s = serial.read;
            if (!s.strip.blank?)
              ss = ss + s;
              if (ss.index('CPIN:') >= 0 || ss.index('ERROR') >= 0)
                isReading = false;
              end
            end
            sleep(1);
            i=i+1;
        end
        modem = Modem.where(name: portname).first
        status = "";
        if (ss.strip.blank?)
            status = Constants::ModemStatus::STATUS_MODEM_ERROR;
        elsif (ss.index(Constants::ModemStatus::STATUS_MODEM_READY) >=0)
            status = Constants::ModemStatus::STATUS_MODEM_READY;
        elsif (ss.index(Constants::ModemStatus::STATUS_MODEM_PIN) >= 0)
            status = Constants::ModemStatus::STATUS_MODEM_PIN;
        elsif (ss.index(Constants::ModemStatus::STATUS_MODEM_PUK) >= 0)
            status = Constants::ModemStatus::STATUS_MODEM_PUK;
        else
            status = Constants::ModemStatus::STATUS_MODEM_NOSIM;
        end
        modem.status = status;
        serial.close;
        modem;
    rescue StandardError => e
      render_rescue(e)
      result = helper_render_message(
        400,
        I18n.t('modem_controller.errors.check_status'),
      )
      halt result[:status], result[:response].to_json     
    end
  end

  def reset_modem(portname)
    begin
        baud_rate = 11500
        data_bits = 8
        stop_bits = 1
        parity = SerialPort::NONE
        portname = portname
        serial = SerialPort.new(portname, baud_rate, data_bits, stop_bits, parity) 
        serial.write Constants::CommandPort::COMMAND_RESET_0
        ss = "";
        i = 0;
        isReading = true;
        while isReading do
            if (i == 10)
              break;
            end
            s = serial.read;
            if (!s.strip.blank?)
                ss = ss + s;
                if (ss.index('OK') >= 0 || ss.index('ERROR') >= 0)
                  isReading = false;
                end
            end
            sleep(1);
            i=i+1;
        end
        sleep(2);
        serial.write Constants::CommandPort::COMMAND_RESET_1
        ss = "";
        i = 0;
        isReading = true;
        while isReading do
            if (i == 10)
              break;
            end
            s = serial.read;
            if (!s.strip.blank?)
                ss = ss + s;
                if (ss.index('OK') >= 0 || ss.index('ERROR') >= 0)
                  isReading = false;
                end
            end
            sleep(1);
            i=i+1;
        end
        serial.close;
    rescue StandardError => ex
      render_rescue(ex)
      if serial
        serial.close;
      end
      result = helper_render_message(
        400,
        I18n.t('modem_controller.errors.reset_modem'),
      )
      halt result[:status], result[:response].to_json     
    end
  end

  #checking modem is active
  def isModemReady(list_modem)
    begin
      list_modem.each do |modem|
          if (modem.status == Constants::ModemStatus::STATUS_MODEM_READY)
             return true
          end
      end
      return false
    rescue StandardError => ex
      render_rescue(ex)
      end
      result = helper_render_message(
        400,
        I18n.t('modem_controller.errors.isModemReady'),
      )
      halt result[:status], result[:response].to_json     
  end


  def isSetIndex(list_modem)
     if (!ModemHelper.isActiveSimBank())
          return false
      end
     list_modem.each do |modem|
        if (modem.status == Constants::ModemStatus::STATUS_MODEM_READY && modem.index.blank?)
            index_simbank = ModemHelper.is_integer(modem.index);
            if(index_simbank <= 0)
                return false
            else
                Modem modem = SQLHelper.Instance.GetModemByName(port);
                if (modem != null)
                    modem.index = index_simbank
                    modem.current_bank =1
                    if modem.save
                      result = helper_render_message(
                        200,
                        I18n.t('common.success.congrate'),
                      )
                    else
                      result = helper_render_message(
                        400,
                        I18n.t('user_controller.errors.update_fail'),
                      )
                    end
                end
            end
        end
      end 
  end

end
