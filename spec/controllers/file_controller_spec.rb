# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
describe 'file_controller' do
  def app
    FileController.new
  end

  # Using to check api success
  # Input: list_response
  # Output: true, false
  def success_multi_api(list_response)
    list_response.each do |res|
      return false if res.status != 200
    end
    true
  end

  # using to conver response to json
  # Input: list_response
  # Output: array
  def get_list_body_json(list_response)
    result = []
    list_response.each do |res|
      result << JSON.parse(res.body)
    end
    result
  end

  # Using to check reponse must to have extra
  # Input: list_response
  # Output: true, false
  def extra_detail(list_response)
    list_response.each do |response|
      return false unless response['extra'].present?
    end
    true
  end

  # Using to check reponse must to have message and common key-value
  # Input: list_response
  # Output: true, false
  def common_response(list_response)
    list_response.each do |response|
      return false if response['message'].blank? || response['common'].blank?
    end
    true
  end

  # Using to check message value in response must to equa value
  # Input: list_response, key
  # Output: true, false
  def check_extra_data_should_have_st(list_response, key, value = '')
    list_response.each do |response|
      return false if response['extra'][key].blank?
      return false if value.present? && response['extra'][key] != value
    end
    true
  end

  # # Using to check message value in response must to equa value
  # # Input: list_response, value
  # # Output: true, false
  def check_message_must_eq(list_response, value)
    list_response.each do |response|
      return false if response['message'].blank? || response['message'] != value
    end
    true
  end

  describe '/create_folder' do
    include_context 'generate_authorized', 'test123'
    context 'success' do
      before do
        post '/create_folder', {}, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
    end
  end

  # Test upload function
  describe '/flow upload' do
    let(:folder_tmp_guid) { Constants::FolderPath::FOLDER_TMP_GUID }
    let(:folder_tmp) { Constants::FolderPath::FOLDER_TMP }
    include_context 'generate_authorized', 'test123'
    before do
      post '/create_folder', {}, 'HTTP_AUTHORIZATION' => session_token
      response = JSON.parse(last_response.body)
      @folder_name = response['extra']['folder_name']
      @files = []
      @files << Rack::Test::UploadedFile.new(File.expand_path('../fixtures/Some note confitg.txt', __dir__), 'application/octet-stream')
      @files << Rack::Test::UploadedFile.new(File.expand_path('../fixtures/Untitled.png', __dir__), 'application/octet-stream')
    end

    # upload multiple file
    describe 'success flow multi file: success' do
      # upload multiple file
      context '/upload' do
        before do
          # Upload the first file
          @list_response = []
          @files.each do |file|
            data = {
              file: file,
              folder_name: @folder_name,
            }
            post '/upload', data, 'HTTP_AUTHORIZATION' => session_token
            @list_response << last_response
          end
        end
        let(:data_upload) { get_list_body_json(@list_response) }

        it 'check_multi_api_success' do
          expect(success_multi_api(@list_response)).to eq(true)
        end

        it 'all api have common_response' do
          expect(common_response(data_upload)).to eq(true)
        end

        it 'all api have extra_detail' do
          expect(extra_detail(data_upload)).to eq(true)
        end

        it 'should have file in tmp_pre_process' do
          @files.each do |file|
            expect(File.file?("#{folder_tmp_guid}/#{@folder_name}/#{file.original_filename}")).to eq(true)
          end
        end
        it 'should have time_upload' do
          expect(check_extra_data_should_have_st(data_upload, 'time_upload'))
        end
      end

      # flow check_virus
      context '/check_virus' do
        context '/when bit_defender service policy enable' do
          before do
            service = Service.bit_defender.first
            service.service_policy.where(system_id: 1).update(status: true)
            @list_response = []
            @files.each do |file|
              # Call api upload
              data = {
                file: file,
                folder_name: @folder_name,
              }
              post '/upload', data, 'HTTP_AUTHORIZATION' => session_token
              # call api check_virus
              data_check_virus = {
                file_name: file.original_filename,
                folder_name: @folder_name,
              }
              post '/check_virus', data_check_virus.to_json, 'HTTP_AUTHORIZATION' => session_token
              @list_response << last_response
            end
          end
          let(:data_check_virus) { get_list_body_json(@list_response) }

          it 'check_multi_api_success' do
            expect(success_multi_api(@list_response)).to eq(true)
          end

          it 'all api have common_response' do
            expect(common_response(data_check_virus)).to eq(true)
          end

          it 'all api have extra_detail' do
            expect(extra_detail(data_check_virus)).to eq(true)
          end

          it 'should contain time_check_virus' do
            expect(check_extra_data_should_have_st(data_check_virus, 'time_check_virus'))
          end

          it 'should contain bit_defender' do
            expect(check_extra_data_should_have_st(data_check_virus, 'bit_defender', '2')).to eq(true)
          end
        end
        context '/when bit_defender service policy disable' do
          before do
            service = Service.bit_defender.first
            service.service_policy.where(system_id: 1).update(status: false)
            @list_response = []
            @files.each do |file|
              # Call api upload
              data = {
                file: file,
                folder_name: @folder_name,
              }
              post '/upload', data, 'HTTP_AUTHORIZATION' => session_token
              # call api check_virus
              data_check_virus = {
                file_name: file.original_filename,
                folder_name: @folder_name,
              }
              post '/check_virus', data_check_virus.to_json, 'HTTP_AUTHORIZATION' => session_token
              @list_response << last_response
            end
          end
          let(:data_check_virus) { get_list_body_json(@list_response) }

          it 'check_multi_api_success' do
            expect(success_multi_api(@list_response)).to eq(true)
          end

          it 'all api have common_response' do
            expect(common_response(data_check_virus)).to eq(true)
          end

          it 'all api have extra_detail' do
            expect(extra_detail(data_check_virus)).to eq(true)
          end

          it 'should contain time_check_virus' do
            expect(check_extra_data_should_have_st(data_check_virus, 'time_check_virus'))
          end

          it 'should contain bit_defender' do
            expect(check_extra_data_should_have_st(data_check_virus, 'bit_defender', '4')).to eq(true)
          end
        end
      end

      context '/mission_complete' do
        before do
          data_mission_complete = {
            folder_name: @folder_name,
            commet_request: 'test_multi_file: okay',
            list_file: [],
          }
          @files.each do |file|
            # Call api upload
            data = {
              file: file,
              folder_name: @folder_name,
            }
            post '/upload', data, 'HTTP_AUTHORIZATION' => session_token
            res_upload = JSON.parse(last_response.body)
            # call api check_virus
            data_check_virus = {
              file_name: file.original_filename,
              folder_name: @folder_name,
            }
            post '/check_virus', data_check_virus.to_json, 'HTTP_AUTHORIZATION' => session_token
            res_check_virus = JSON.parse(last_response.body)
            data_mission_complete[:list_file] << {
              file_name: file.original_filename,
              bit_defender: res_check_virus['extra']['bit_defender'],
              time_check_virus: res_check_virus['extra']['time_check_virus'],
              time_upload: res_upload['extra']['time_upload'],
            }
          end
          post '/mission_completed', data_mission_complete.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'success_api'
        include_examples 'common_response'
        include_examples 'extra_detail'

        it 'should contain list_id' do
          response = JSON.parse(last_response.body)
          expect(response['extra']['list_id'].present?).to eq(true)
        end

        it 'should have file in db' do
          result = true
          response = JSON.parse(last_response.body)
          response['extra']['list_id'].each { |id| result = false unless Files.where(id: id.to_i).exists? }
          expect(result).to eq(true)
        end

        it 'should have file in FOLDER_TMP' do
          result = true
          response = JSON.parse(last_response.body)
          response['extra']['list_id'].each do |id|
            f = Files.find(id.to_i)
            result = false unless File.file?("#{folder_tmp}/#{f.filename_system}")
          end
          expect(result).to eq(true)
        end
      end

      context '/kill_virus' do
        before do
          data_mission_complete = {
            folder_name: @folder_name,
            commet_request: 'test_multi_file: okay',
            list_file: [],
          }
          @files.each do |file|
            # Call api upload
            data = {
              file: file,
              folder_name: @folder_name,
            }
            post '/upload', data, 'HTTP_AUTHORIZATION' => session_token
            res_upload = JSON.parse(last_response.body)
            # call api check_virus
            data_check_virus = {
              file_name: file.original_filename,
              folder_name: @folder_name,
            }
            post '/check_virus', data_check_virus.to_json, 'HTTP_AUTHORIZATION' => session_token
            res_check_virus = JSON.parse(last_response.body)
            data_mission_complete[:list_file] << {
              file_name: file.original_filename,
              bit_defender: res_check_virus['extra']['bit_defender'],
              time_check_virus: res_check_virus['extra']['time_check_virus'],
              time_upload: res_upload['extra']['time_upload'],
            }
          end
          post '/mission_completed', data_mission_complete.to_json, 'HTTP_AUTHORIZATION' => session_token
          res_mission_completed = JSON.parse(last_response.body)
          data_kill_virus = {
            list_file: res_mission_completed['extra']['list_id'],
          }
          post '/kill_virus', data_kill_virus.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'success_api'
        include_examples 'common_response'
      end
    end
  end

  # Describe: These unit test are using for api '/download'
  describe '/download' do
    include_context 'generate_authorized', 'test123'
    # when download success
    context 'download success' do
      # check download success single file outside
      context 'success single file' do
        before do
          @file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [2, 4],
              system_id_request: 0,
            },
          ).first
          data = {
            list_file: [@file.id],
            time_client: Time.now.strftime('%m/%d/%Y %H:%M:%S'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'success_api'
      end

      # check download success single file inside
      context 'success single file outside' do
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          Files.where(id: 73).update(
            is_deleted: false,
          )
          data = {
            list_file: [73],
            time_client: Time.now.strftime('%m/%d/%Y %H:%M:%S'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        include_examples 'success_api'
      end

      # check download in approval screen
      context 'success in approval screen' do
        before do
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: 28,
              system_id_request: 1,
              status: 1,
            },
          ).first
          data = {
            list_file: [file.id],
            time_client: Time.now.strftime('%m/%d/%Y %H:%M:%S'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'success_api'
      end

      # check download success multi file
      context 'success multi file' do
        before do
          # files = Files.is_present.joins(:request).where(
          #   request: {
          #     user_id_request: current_user.id,
          #     status: [2, 4],
          #     system_id_request: 0,
          #   },
          # ).limit(2)
          current_time = Time.now
          @expect_file_name = "#{current_time.strftime('%Y%m%d%H%M%S%L')}.zip"
          @list_id = [70, 69]
          data = {
            list_file: @list_id,
            time_client: current_time.strftime('%m/%d/%Y %H:%M:%S:%L'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
          sleep 1.4
        end
        include_examples 'success_api'

        it 'should have filename' do
          content_diposition = last_response.headers['content-disposition']
          file_name = content_diposition.split('filename=').last.to_s.gsub('"', '')
          expect(file_name).to eq(@expect_file_name)
        end

        # Check has record in file_history in db
        it 'should update history' do
          result = true
          @list_id.each do |id|
            history = FileHistory.where(
              user_id: current_user.id,
              file_id: id,
              action: 2,
              system_id: 1,
            )
            unless history.exists?
              result = false
              break
            end
          end
          expect(result).to eq(true)
        end
      end
    end
    # download fail
    context 'when download fail' do
      # can't download, current user is not user approval
      context 'fail in approval screen' do
        before do
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: 2,
              system_id_request: 1,
              status: 1,
            },
          ).first
          data = {
            list_file: [file.id],
            time_client: Time.now.strftime('%m/%d/%Y %H:%M:%S'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
      end

      # download fail when missing params
      context 'when missing params' do
        # missing param list_file
        context 'when missing param list_file' do
          before do
            current_time = Time.now
            data = {
              list_file: [],
              time_client: current_time.strftime('%m/%d/%Y %H:%M:%S:%L'),
            }
            post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
          end
          include_examples 'failure_api'
        end
        # missing param time_client
        context 'when missing param time_client' do
          before do
            data = {
              list_file: [],
              time_client: nil,
            }
            post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
          end
          include_examples 'failure_api'
        end
      end
      # can't download when rejected file
      context 'download when rejected file' do
        before do
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              system_id_request: 0,
              status: 3,
            },
          ).first
          data = {
            list_file: [file.id],
            time_client: Time.now.strftime('%m/%d/%Y %H:%M:%S:%L'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
      end

      # check file exist
      context 'file not exist' do
        before do
          current_time = Time.now
          data = {
            list_file: [10_202],
            time_client: current_time.strftime('%m/%d/%Y %H:%M:%S:%L'),
          }
          post '/download', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'
        include_examples 'extra_detail'
        # Then return error message: ERR_MEM_0003
        it 'should return ERR_MEM_0003' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0003')
        end

        it 'response should include extra' do
          response = JSON.parse(last_response.body)
          expect(response['extra'].present?).to eq(true)
        end
      end

      # check missing Authorization
      context 'when missing Authorization' do
        before do
          post '/download'
        end
        include_examples 'unauthorized'
        it 'Unauthorized' do
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  # Describe: These unit test are using for api '/approval_file'
  describe '/approval_file' do
    include_context 'generate_authorized', 'test123'
    # when approval file success
    context 'when approval file success' do
      before do
        # set policy to no required download or preview to approve the file
        ApprovalPolicy.where(system_id: 1).update(
          require_download: false,
          require_preview: false,
        )
        # get file
        file = Files.is_present.joins(:request).where(
          request: {
            user_id_request: current_user.id,
            status: 1,
            system_id_request: 1,
          },
        ).first
        @list_id = [file.id]
        data = { list_file: @list_id }
        post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'

      # Check has record in file_history in db
      it 'should update history' do
        result = true
        @list_id.each do |id|
          history = FileHistory.where(
            user_id: current_user.id,
            file_id: id,
            action: 6,
            system_id: 1,
          )
          unless history.exists?
            result = false
            break
          end
        end
        expect(result).to eq(true)
      end
    end
    context 'when approval file fail' do
      # missing param
      context 'when missing param list_file' do
        before do
          data = { list_file: [] }
          post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
      end
      # check have to download or review to approve the file
      # Then return error message: ERR_MEM_0008
      context 'have not to download or review to approve' do
        before do
          # set policy to required download or preview to approve the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: true,
            require_preview: true,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [1],
              system_id_request: 1,
            },
          ).first

          data = { list_file: [file.id] }
          post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0008' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0008')
        end
      end
      # check have to download to approve the file
      # Then return error message: ERR_MEM_0016
      context 'have not to download to approve' do
        before do
          # set policy to required download to approve the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: true,
            require_preview: false,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [1],
              system_id_request: 1,
            },
          ).first

          data = { list_file: [file.id] }
          post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0016' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0016')
        end
      end
      # check have to preview to approve the file
      # Then return error message: ERR_MEM_0017
      context 'have not to preview to approve' do
        before do
          # set policy to required preview to approve the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: false,
            require_preview: true,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [1],
              system_id_request: 1,
            },
          ).first

          data = { list_file: [file.id] }
          post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0017' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0017')
        end
      end
      # chek have not to approve the file
      # Then return error message: ERR_MEM_0018
      context 'file approved' do
        before do
          # set policy to required preview to approve the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: false,
            require_preview: false,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [2, 4],
              system_id_request: 1,
            },
          ).first

          data = { list_file: [file.id] }
          post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0018' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0018')
        end
      end
      # check missing Authorization
      context 'when missing Authorization' do
        before do
          post '/approval_file'
        end
        include_examples 'unauthorized'
        it 'Unauthorized' do
          expect(last_response.status).to eq(401)
        end
      end
      # check file_not_existed
      context 'when file was not in db' do
        before do
          data = { list_file: [1] }
          post '/approval_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'should have message: ERR_MEM_0006' do
          response = JSON.parse(last_response.body)
          expect(check_message_must_eq([response], 'ERR_MEM_0006'))
        end
      end
    end
  end

  # Describe: These unit test are using for api '/denied_file'
  describe '/denied_file' do
    include_context 'generate_authorized', 'test123'
    # when reject file success
    context 'when reject file success' do
      before do
        # set policy to no required download or preview to approve the file
        ApprovalPolicy.where(system_id: 1).update(
          require_download: false,
          require_preview: false,
        )
        # get file
        file = Files.is_present.joins(:request).where(
          request: {
            user_id_request: current_user.id,
            status: [1],
            system_id_request: 1,
          },
        ).first
        @list_id = [file.id]
        data = {
          list_file: @list_id,
          comment_approval: 'comment denied file',
        }
        post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
      # Check has record in file_history in db
      it 'should update history' do
        result = true
        @list_id.each do |id|
          history = FileHistory.where(
            user_id: current_user.id,
            file_id: id,
            action: 7,
            system_id: 1,
          )
          unless history.exists?
            result = false
            break
          end
        end
        expect(result).to eq(true)
      end
    end
    # when reject file fail
    context 'when reject file fail' do
      # missing param
      context 'when missing params' do
        # missing param list_file
        context 'when missing param list_file' do
          before do
            data = {
              list_file: [],
              comment_approval: 'comment denied file',
            }
            post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
          end
          include_examples 'failure_api'
        end
        # missing param comment_approval
        context 'when missing param comment_approval' do
          before do
            file = Files.is_present.joins(:request).where(
              request: {
                user_id_request: current_user.id,
                status: [1],
                system_id_request: 1,
              },
            ).first
            data = {
              list_file: [file.id],
              comment_approval: '',
            }
            post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
          end
          include_examples 'failure_api'
        end
      end
      # check have to download or review to reject the file
      # Then return error message: ERR_MEM_0007
      context 'have not to download or review to reject' do
        before do
          # set policy to required download or preview to reject the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: true,
            require_preview: true,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [1],
              system_id_request: 1,
            },
          ).first
          data = {
            list_file: [file.id],
            comment_approval: 'comment denied file',
          }
          post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0007' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0007')
        end
      end
      # check have to download to reject the file
      # Then return error message: ERR_MEM_0014
      context 'have not to download to reject' do
        before do
          # set policy to required download to reject the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: true,
            require_preview: false,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [1],
              system_id_request: 1,
            },
          ).first

          data = {
            list_file: [file.id],
            comment_approval: 'comment denied file',
          }
          post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0014' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0014')
        end
      end
      # check have to preview to reject the file
      # Then return error message: ERR_MEM_0015
      context 'have not to preview to reject' do
        before do
          # set policy to required preview to reject the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: false,
            require_preview: true,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [1],
              system_id_request: 1,
            },
          ).first

          data = {
            list_file: [file.id],
            comment_approval: 'comment denied file',
          }
          post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0015' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0015')
        end
      end
      # chek have not to reject the file
      # Then return error message: ERR_MEM_0018
      context 'file rejected' do
        before do
          # set policy to required preview to approve the file
          ApprovalPolicy.where(system_id: 1).update(
            require_download: false,
            require_preview: false,
          )
          # get file
          file = Files.is_present.joins(:request).where(
            request: {
              user_id_request: current_user.id,
              status: [2, 4],
              system_id_request: 1,
            },
          ).first
          data = {
            list_file: [file.id],
            comment_approval: 'comment denied file',
          }
          post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0018' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0018')
        end
      end
      # check missing Authorization
      context 'when missing Authorization' do
        before do
          post '/denied_file'
        end
        include_examples 'unauthorized'
        it 'Unauthorized' do
          expect(last_response.status).to eq(401)
        end
      end
      # check file_not_existed
      context 'when file was not in db' do
        before do
          data = {
            list_file: [1],
            comment_approval: 'comment denied file',
          }
          post '/denied_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'should have message: ERR_MEM_0005' do
          response = JSON.parse(last_response.body)
          expect(check_message_must_eq([response], 'ERR_MEM_0005'))
        end
      end
    end
  end

  # Describe: These unit test are using for api '/delete_file'
  describe '/delete_file' do
    include_context 'generate_authorized', 'test123'
    # when delete file success
    context 'when delete file success' do
      before do
        file = Files.is_present.joins(:request).where(
          request: {
            user_id_request: current_user.id,
            system_id_request: 1,
          },
        ).first
        @list_id = [file.id]
        data = { list_file: @list_id }
        post '/delete_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
      # Check has record in file_history in db
      it 'should update history' do
        result = true
        @list_id.each do |id|
          history = FileHistory.where(
            user_id: current_user.id,
            file_id: id,
            action: 3,
            system_id: 1,
          )
          unless history.exists?
            result = false
            break
          end
        end
        expect(result).to eq(true)
      end
    end
    # when delete file fail
    context 'when delete file fail' do
      # missing param
      context 'when missing param list_file' do
        before do
          data = { list_file: [] }
          post '/delete_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
      end
      # check file exist
      # Then return error message: ERR_MEM_0004
      context 'file not exist' do
        before do
          data = { list_file: [1_233_445] }
          post '/delete_file', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'failure_api'
        include_examples 'common_response'

        it 'it should return ERR_MEM_0004' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_MEM_0004')
        end
      end
      # check missing Authorization
      context 'when missing Authorization' do
        before do
          post '/delete_file'
        end
        include_examples 'unauthorized'
        it 'Unauthorized' do
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  # Describe: These unit test are using for api '/list_file_download'
  describe '/list_file_download' do
    include_context 'generate_authorized', 'test123'
    # when get list file download success
    context 'when list file download success' do
      before do
        get '/list_file_download', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
    end
    # when get file download fail
    context 'when get list file download fail' do
      # check missing Authorization
      context 'when missing Authorization' do
        before do
          get '/list_file_download'
        end
        include_examples 'unauthorized'
        it 'Unauthorized' do
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  # Describe: These unit test are using for api '/move_file_to_personal_folder'
  describe '/move_file_to_personal_folder' do
    include_context 'generate_authorized', 'test123'
    # when move file to personal folder success outside
    context 'when move file to personal folder success' do
      before do
        post '/move_file_to_personal_folder', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
    end
    # check move file inside
    context 'when move file to personal folder success in network inside' do
      before do
        SystemParamValue.where(system_param_id: 60).update(
          value: '127.0.0.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '127.0.0.255',
        )

        post '/move_file_to_personal_folder', nil, 'HTTP_AUTHORIZATION' => session_token

        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
      end
      include_examples 'success_api'
    end
    # when move file to personal folder fail
    context 'when move file to personal folder fail' do
      # check missing Authorization
      context 'when missing Authorization' do
        before do
          get '/list_file_download'
        end
        include_examples 'unauthorized'
        it 'Unauthorized' do
          expect(last_response.status).to eq(401)
        end
      end
    end
  end
end
