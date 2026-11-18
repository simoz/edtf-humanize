# frozen_string_literal: true

module Edtf
  module Humanize
    module Language
      module Default
        module Set
          include Edtf::Humanize::Language::Default::Formats

          extend self

          def humanizer(date)
            format_set_entries(date).to_sentence(
              words_connector:
                I18n.t("edtf.terms.set_dates_connector_#{mode(date)}",
                       default: ', '),
              last_word_connector:
                I18n.t("edtf.terms.set_last_date_connector_#{mode(date)}",
                       default: default_word_connector(date)),
              two_words_connector:
                I18n.t("edtf.terms.set_two_dates_connector_#{mode(date)}",
                       default: default_word_connector(date))
            )
          end

          private

          def default_word_connector(date)
            mode(date) == 'inclusive' ? ' and ' : ' or '
          end

          def format_set_entries(dates)
            entries = dates.entries
            entries.map.with_index do |date, index|
              "#{apply_if_earlier(dates, index)}" \
                "#{apply_if_later(dates, index, entries.size)}" \
                "#{format_set_entry(date)}"
            end
          end

          # edtf 5 sets can also hold decades and centuries, which humanize
          # themselves: '[196X,1972]' => 1960s or 1972
          def format_set_entry(date)
            return date.humanize unless date.is_a?(::Date)

            "#{apply_prefix_if_approximate(date)}" \
              "#{date_format(date)}" \
              "#{apply_suffix_if_approximate(date)}"
          end

          # '[..1760-12-03]' => on or before December 3, 1760
          def apply_if_earlier(dates, index)
            earlier_prefix(dates) if dates.earlier? && index.zero?
          end

          def earlier_prefix(dates)
            I18n.t("edtf.terms.set_earlier_prefix_#{mode(dates)}",
                   default: earlier_prefix_default(dates))
          end

          def earlier_prefix_default(dates)
            mode(dates) == 'inclusive' ? 'on and before ' : 'on or before '
          end

          # '[1760-12..]' => on or after December 1760
          def apply_if_later(dates, index, size)
            later_prefix(dates) if dates.later? && (index + 1) == size
          end

          def later_prefix(dates)
            I18n.t("edtf.terms.set_later_prefix_#{mode(dates)}",
                   default: later_prefix_default(dates))
          end

          def later_prefix_default(dates)
            mode(dates) == 'inclusive' ? 'on and after ' : 'on or after '
          end

          # edtf 5 has separate classes: EDTF::Set ([...], one of the dates)
          # and EDTF::List ({...}, all of them)
          def mode(date)
            choice = date.respond_to?(:choice?) ? date.choice? : date.is_a?(EDTF::Set)
            choice ? 'exclusive' : 'inclusive'
          end
        end
      end
    end
  end
end
