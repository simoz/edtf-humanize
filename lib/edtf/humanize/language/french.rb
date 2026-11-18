# frozen_string_literal: true

module Edtf
  module Humanize
    module Language
      module French
        include Default

        module Century
          extend self

          def humanizer(date)
            "#{RomanNumerals.to_roman((date.begin.year.abs / 100) + 1)}" \
              "#{century_number_suffix(date)}" \
              "#{century_sign_suffix(date)}"
          end

          private

          def century_number_suffix(date)
            return 'er siècle' if (date.begin.year.abs / 100).zero?

            'e siècle'
          end

          def century_sign_suffix(date)
            return ' avant J.C.' if date.begin.year.negative?

            ''
          end
        end

        # Decade and century endpoints contract the article with the
        # preposition: '198X/199X' => Des années 1980 aux années 1990
        module Interval
          include Default::Interval

          extend self

          def humanizer(date)
            return super if [date.from, date.to].any?(Symbol)
            return super unless span_endpoint?(date.from) || span_endpoint?(date.to)

            "#{from_phrase(date)}#{to_phrase(date)}"
          end

          private

          def from_phrase(date)
            span_phrase(date.from, decade: 'Des années', century: 'Du') ||
              "#{interval_prefix(date)}#{formatted_date(date.from)}"
          end

          def to_phrase(date)
            span = span_phrase(date.to, decade: 'aux années', century: 'au')
            span ? " #{span}" : "#{interval_connector(date)}#{formatted_date(date.to)}"
          end

          # Des années 1980 (année inconnue), au XXIe siècle (année inconnue)
          def span_phrase(endpoint, decade:, century:)
            phrase = case span_kind(endpoint)
                     when :decade then "#{decade} #{decade_years(endpoint)}"
                     when :century
                       "#{century} #{Century.humanizer(epoch_of_year(EDTF::Century, first_year(endpoint)))}"
                     end
            annotate_unknown_parts(phrase, unknown_parts(endpoint)) if phrase
          end

          def span_endpoint?(endpoint)
            !span_kind(endpoint).nil?
          end

          # edtf 5 parses '198X' and '19XX' as a decade and a century, edtf 3
          # and 4 as years with unspecified digits. Only year-precision dates;
          # '198X-05' keeps the default wording
          def span_kind(endpoint)
            case endpoint
            when EDTF::Decade then :decade
            when EDTF::Century then :century
            when ::Date
              unspecified_year_kind(endpoint) if endpoint.unspecified?(:year) && known_precision(endpoint) == :year
            end
          end

          # edtf 5 decades and centuries have no #year, and are never negative
          def first_year(endpoint)
            endpoint.is_a?(::Date) ? endpoint.year : endpoint.begin.year
          end

          def decade_years(endpoint)
            year = first_year(endpoint)
            return year.to_s unless year.negative?

            "#{year.abs}#{I18n.t('edtf.terms.bc_suffix', default: ' avant J.C.')}"
          end
        end
      end
    end
  end
end
