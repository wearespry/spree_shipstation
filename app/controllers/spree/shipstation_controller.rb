include SpreeShipstation

module Spree
  class ShipstationController < Spree::StoreController
    include BasicSslAuthentication
    include Spree::DateParamHelper

    skip_before_filter :verify_authenticity_token

    def export
      @shipments = Spree::Shipment.exportable
                           .between(date_param(:start_date),
                                    date_param(:end_date))
                           .page(params[:page])
                           .per(50)
    end

    def shipnotify
      notice = Spree::ShipmentNotice.new(params)

      if notice.apply

        logger.info 'ShipNotify Params:'
        logger.info params
        logger.info ''

        ord = Spree::Shipment.find_by_number(params[:order_number]).order

        ord.update_columns(
          shipment_state: 'shipped',
          updated_at: Time.now,
        )

        render(text: 'success')
      else
        render(text: notice.error, status: :bad_request)
      end
    end
  end
end
