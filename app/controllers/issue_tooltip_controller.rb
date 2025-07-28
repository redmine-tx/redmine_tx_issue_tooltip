class IssueTooltipController < ApplicationController
  # include ApplicationHelper 

  def issue_detail
    begin
        @issue = Issue.find(params[:id])

        # TODO : 이슈의 프로젝트 ( @issue.project_id )접근 가능한지 권한 체크 해야함
        unless true
            render json: { success: false, error: 'Permission denied' }
            return
        end
        
        # 이슈 상세 정보 JSON 구성
        issue_data = {
          id: @issue.id,
          subject: @issue.subject,
          description: @issue.description,
          status: @issue.status.name,
          priority: @issue.priority.name,
          tracker: @issue.tracker.name,
          project: @issue.project.name,
          author: @issue.author.name,
          assigned_to: @issue.assigned_to ? @issue.assigned_to.name : nil,
          category: @issue.category ? @issue.category.name : nil,
          fixed_version: @issue.fixed_version ? ( @issue.respond_to?(:fixed_version_plus) ? @issue.fixed_version_plus : @issue.fixed_version.name ) : nil,
          created_on: @issue.created_on,
          updated_on: @issue.updated_on,
          start_date: @issue.start_date,
          due_date: @issue.due_date,
          done_ratio: @issue.done_ratio,
          estimated_hours: @issue.estimated_hours,
          spent_hours: @issue.spent_hours,
          parent: @issue.parent ? "##{@issue.parent.id} #{@issue.parent.subject}" : nil,
          childrens: @issue.children.map do |child|
            {
              id: child.id,
              subject: child.subject,
              status: child.status.name,
              done_ratio: child.done_ratio
            }
          end,
          # 마일스톤 관련 추가 정보
          worker: @issue.worker_id ? Principal.find(@issue.worker_id).name : nil,
          begin_time: @issue.respond_to?(:begin_time) ? @issue.begin_time : nil,
          end_time: @issue.respond_to?(:end_time) ? @issue.end_time : nil,
          attachments: @issue.attachments.map do |attachment|
            {
              id: attachment.id,
              filename: attachment.filename,
              content_type: attachment.content_type,
              url: "/issue_tooltip/attachment_file/#{attachment.id}"
              #url: "https://redmine-ssr.supercreative.kr/issue_tooltip/attachment_file/#{attachment.id}"
            }
          end
        }
        
        render json: {
          success: true,
          issue: issue_data
        }
        
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: '해당 이슈를 찾을 수 없습니다.',
          error_code: 'ISSUE_NOT_FOUND'
        }, status: :not_found
        
      rescue => e
        Rails.logger.error "이슈 상세 정보 조회 중 오류 발생: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: {
          success: false,
          message: '이슈 정보를 가져오는 중 오류가 발생했습니다.',
          error_code: 'SERVER_ERROR',
          error_details: e.message
        }, status: :internal_server_error
    end
  end

  # 첨부파일을 인라인으로 서빙하는 액션
  def attachment_file
    begin
      @attachment = Attachment.find(params[:id])
      
      # 권한 체크
      unless @attachment.visible?
        render_404
        return
      end
      
      # 파일이 존재하고 읽을 수 있는지 확인
      unless @attachment.readable?
        render_404
        return
      end

      # 다운로드 카운트 증가 (필요한 경우)
      if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
        @attachment.increment_download
      end

      # Content-Type 감지
      content_type = @attachment.content_type
      if content_type.blank? || content_type == "application/octet-stream"
        content_type = Redmine::MimeType.of(@attachment.filename).presence || "application/octet-stream"
      end

      # 첨부파일을 인라인으로 전송
      send_file @attachment.diskfile, 
                :filename => filename_for_content_disposition(@attachment.filename),
                :type => content_type,
                :disposition => 'inline'  # 여기가 핵심! inline으로 설정

    rescue ActiveRecord::RecordNotFound
      render_404
    rescue => e
      Rails.logger.error "첨부파일 조회 중 오류 발생: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render_404
    end
  end

  private

  def render_404
    head :not_found
  end

  def filename_for_content_disposition(filename)
    request.user_agent =~ /msie|trident/i ? ERB::Util.url_encode(filename) : filename
  end
end
