##
# Mailer to deliver a survey to users who have recently made a request for
# information
#
class SurveyMailer < ApplicationMailer
  include AlaveteliFeatures::Helpers

  before_action :set_footer_template

  def survey_alert(info_request)
    return unless Survey.enabled?

    user = info_request.user

    post_redirect = PostRedirect.new(
      uri: survey_url,
      user_id: user.id
    )
    post_redirect.save!
    @url = confirm_url(email_token: post_redirect.email_token)
    @info_request = info_request

    headers(
      'Return-Path' => blackhole_email,
      'Reply-To' => contact_from_name_and_email,
      'Auto-Submitted' => 'auto-generated',
      'X-Auto-Response-Suppress' => 'OOF'
    )

    mail(
      to: user.name_and_email,
      from: contact_from_name_and_email,
      subject: 'Can you help us improve WhatDoTheyKnow?'
    )
  end

  # Send an email with a link to the survey two weeks after a request was made,
  # if the user has not already completed the survey.
  def self.alert_survey
    return unless Survey.enabled?

    InfoRequest.surveyable.each do |info_request|
      # Exclude users who have already completed the survey or
      # have already been sent a survey email in this run
      logger.debug "[alert_survey] Considering #{info_request.user.url_name}"
      next unless info_request.user.can_send_survey?

      store_sent = UserInfoRequestSentAlert.new(
        info_request: info_request,
        user: info_request.user,
        alert_type: 'survey_1',
        info_request_event_id: info_request.info_request_events.first.id
      )

      SurveyMailer.survey_alert(info_request).deliver_now
      store_sent.save!
    end
  end

  private

  def set_footer_template
    @footer_template = 'default'
  end
end
