# frozen_string_literal: true

module Edtf
  module Humanize
    module Language
      module Default
        module Season
          include Edtf::Humanize::Language::Default::Formats

          extend self

          SEASON_NAMES = %i[spring summer autumn winter].freeze

          def humanizer(date)
            "#{apply_prefix_if_uncertain(date)}" \
              "#{apply_prefix_if_approximate(date)}" \
              "#{season_and_year(date)}" \
              "#{apply_suffix_if_approximate(date)}" \
              "#{apply_suffix_if_uncertain(date)}"
          end

          private

          # EDTF::Season has no precision, so use the year-precision terms
          # '1999-21~' => circa spring 1999
          def apply_prefix_if_approximate(date)
            return '' unless date.approximate?

            I18n.t('edtf.terms.approximate_date_prefix_year', default: 'circa ')
          end

          # '1999-21~' => printemps 1999 environ
          def apply_suffix_if_approximate(date)
            return '' unless date.approximate?

            I18n.t('edtf.terms.approximate_date_suffix_year', default: '')
          end

          def season_and_year(date)
            name = season_name(date.season)
            return "#{translate_season(name)} #{date.year}" if name

            months_span(date)
          end

          # edtf 3 and 4 name the season (:summer); edtf 5 gives its ISO 8601-2
          # code. 21-24 are the seasons, 25-28 and 29-32 the same seasons in the
          # northern and southern hemispheres: '2001-29' => spring 2001
          def season_name(season)
            return season unless season.is_a?(Integer)

            SEASON_NAMES[(season - 21) % 4] if season.between?(21, 32)
          end

          # Quarters, quadrimesters and semesters (edtf 5 codes 33-41) have no
          # name, so show the months they span: '2001-33' => January 2001 to March 2001
          def months_span(date)
            from, to = [date.begin, date.end].map { |day| EDTF::Date.new(day.year, day.month) }
            Edtf::Humanize::Language.language_strategy::Interval.humanizer(EDTF::Interval.new(from, to))
          end

          def translate_season(season)
            I18n.translate!("date.seasons.#{season}")
          rescue I18n::MissingTranslationData
            season
          end
        end
      end
    end
  end
end
