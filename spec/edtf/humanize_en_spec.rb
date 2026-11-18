# frozen_string_literal: true

require 'edtf-humanize'

RSpec.describe Edtf::Humanize do
  before do
    I18n.locale = :en
  end

  it { is_expected.to be_a(Module) }

  context 'with the language strategy' do
    it 'returns the strategy for the current locale' do
      expect(Edtf::Humanize::Language.language_strategy).to(
        eq(Edtf::Humanize::Language::English)
      )
    end

    it 'is not a public method on humanizable objects' do
      %w[1975-07-01 1975-22 1970/1980 [1667,1668] {1667,1668} XXXX 197x 19xx].each do |edtf|
        expect(EDTF.parse!(edtf)).not_to respond_to(:language_strategy)
      end
    end
  end

  context 'with a decade' do
    it 'returns a humanized decade string' do
      expect(EDTF.parse!('199x').humanize).to eq('1990s')
    end

    it 'returns a humanized BC decade string', :edtf4_or_earlier do
      expect(EDTF::Decade.new(-10).humanize).to eq('10s BCE')
    end
  end

  context 'with a century' do
    it 'returns a humanized century string' do
      expect(EDTF.parse!('19xx').humanize).to eq('20th century')
    end

    it 'returns a humanized first century string' do
      expect(EDTF.parse!('00xx').humanize).to eq('1st century')
    end

    it 'returns a humanized 11th century string' do
      expect(EDTF.parse!('10xx').humanize).to eq('11th century')
    end

    it 'returns a humanized 21st century string' do
      expect(EDTF.parse!('20xx').humanize).to eq('21st century')
    end

    it 'returns a humanized BC century string', :edtf4_or_earlier do
      expect(EDTF::Century.new(-100).humanize).to eq('2nd century BCE')
    end
  end

  context 'with an interval' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/1980').humanize).to eq('1970 to 1980')
    end

    # edtf 5 reads 197X and 19XX as a decade and a century unless told
    # otherwise; edtf 3 and 4 ignore the option
    it 'returns a humanized interval string with unspecified decades' do
      expect(EDTF.parse!('198X/199X', centuries: false).humanize).to eq('1980s (year unknown) to 1990s (year unknown)')
    end

    it 'returns a humanized interval string with unspecified centuries' do
      expect(EDTF.parse!('19XX/20XX', centuries: false).humanize).to(
        eq('20th century (year unknown) to 21st century (year unknown)')
      )
    end

    it 'returns a humanized interval string with unspecified a year and a decade' do
      expect(EDTF.parse!('1985/199X', centuries: false).humanize).to eq('1985 to 1990s (year unknown)')
    end
  end

  context 'with decades and centuries as edtf 5 reads them', :edtf5 do
    it 'returns a humanized decade string' do
      expect(EDTF.parse!('198X').humanize).to eq('1980s')
    end

    it 'returns a humanized century string' do
      expect(EDTF.parse!('19XX').humanize).to eq('20th century')
    end

    it 'returns a humanized interval string between decades' do
      expect(EDTF.parse!('198X/199X').humanize).to eq('1980s to 1990s')
    end

    it 'returns a humanized interval string from a year to a decade' do
      expect(EDTF.parse!('1985/199X').humanize).to eq('1985 to 1990s')
    end

    it 'returns a humanized set string with a decade' do
      expect(EDTF.parse!('[198X,1990]').humanize).to eq('1980s or 1990')
    end
  end

  context 'with an open interval' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/open').humanize).to eq('since 1970')
    end
  end

  context 'with an unknown interval start' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('unknown/1970').humanize).to eq('unknown date to 1970')
    end
  end

  context 'with an unknown interval end' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/unknown').humanize).to eq('1970 to unknown date')
    end
  end

  context 'with an approximate interval'
  it 'returns a humanized approximate interval string' do
    expect(EDTF.parse!('1970~/1980~').humanize).to(
      eq('circa 1970 to circa 1980')
    )
  end

  context 'with an iso date' do
    it 'returns a humanized ISO date string' do
      expect(EDTF.parse!('1975-07-01').humanize).to eq('July 1, 1975')
    end

    it 'returns a humanized date-time string' do
      expect(EDTF.parse!('1975-07-01T10:10:10Z').humanize).to eq('July 1, 1975')
    end

    it 'returns a humanized string for a plain Ruby date' do
      expect(Date.new(1975, 7, 1).humanize).to eq('July 1, 1975')
    end
  end

  context 'with an uncertain iso date' do
    it 'returns a humanized uncertain ISO date string' do
      expect(EDTF.parse!('1975?').humanize).to eq('1975?')
    end
  end

  context 'with an unspecified year iso date' do
    it 'returns a humanized unspecified year ISO date string' do
      expect(EDTF.parse!('197X', centuries: false).humanize).to eq('1970s (year unknown)')
    end

    it 'returns a humanized unspecified year in a century string' do
      expect(EDTF.parse!('19XX', centuries: false).humanize).to eq('20th century (year unknown)')
    end

    it 'returns a humanized unspecified year string for legacy u syntax' do
      expect(EDTF.parse!('197u', centuries: false).humanize).to eq('1970s (year unknown)')
    end

    it 'returns a humanized unspecified year string for year 0' do
      expect(EDTF.parse!('00XX', centuries: false).humanize).to eq('1st century (year unknown)')
    end

    it 'returns a humanized unspecified year string for years 100-999' do
      expect(EDTF.parse!('01XX', centuries: false).humanize).to eq('2nd century (year unknown)')
    end

    it 'returns a humanized unspecified year string for negative years' do
      expect(EDTF.parse!('-01XX').humanize).to eq('2nd century BCE (year unknown)')
    end

    it 'returns a humanized unspecified year string for negative decades' do
      expect(EDTF.parse!('-001X').humanize).to eq('10s BCE (year unknown)')
    end

    it 'returns a humanized unspecified year string with month precision' do
      expect(EDTF.parse!('198X-05').humanize).to eq('May, 1980s (year unknown)')
    end

    it 'returns a humanized unspecified year string with day precision' do
      expect(EDTF.parse!('198X-05-03').humanize).to eq('May 3, 1980s (year unknown)')
    end

    it 'returns a humanized unspecified year in a century string with month precision' do
      expect(EDTF.parse!('00XX-05').humanize).to eq('May, 1st century (year unknown)')
    end

    it 'returns a humanized unspecified year string in a set' do
      expect(EDTF.parse!('[198X,1990]', centuries: false).humanize).to eq('1980s (year unknown) or 1990')
    end
  end

  context 'with an unspecified month or day' do
    it 'returns a humanized string with an unspecified month' do
      expect(EDTF.parse!('1990-XX').humanize).to eq('1990 (month unknown)')
    end

    it 'returns a humanized string with an unspecified day' do
      expect(EDTF.parse!('1990-05-XX').humanize).to eq('May 1990 (day unknown)')
    end

    it 'returns a humanized string with an unspecified month and day' do
      expect(EDTF.parse!('1990-XX-XX').humanize).to eq('1990 (exact date unknown)')
    end

    # Known limitation: the known day (15) is dropped, because the day
    # formats need a month name. Rare in practice; revisit if real data
    # needs it.
    it 'returns a humanized string with an unspecified month with a known day' do
      expect(EDTF.parse!('1990-XX-15').humanize).to eq('1990 (month unknown)')
    end

    it 'returns a humanized string with an unspecified year and day' do
      expect(EDTF.parse!('198X-05-XX').humanize).to eq('May, 1980s (exact date unknown)')
    end

    it 'returns a humanized string with an unspecified year, month and day' do
      expect(EDTF.parse!('198X-XX-XX').humanize).to eq('1980s (exact date unknown)')
    end

    it 'returns a humanized string with an unspecified month in a set' do
      expect(EDTF.parse!('[1990-XX,1991]').humanize).to eq('1990 (month unknown) or 1991')
    end

    it 'returns a humanized string with an unspecified month in an interval' do
      expect(EDTF.parse!('1990-XX/1991').humanize).to eq('1990 (month unknown) to 1991')
    end
  end

  context 'with a season' do
    it 'returns a humanized season string' do
      expect(EDTF.parse!('1975-22').humanize).to eq('summer 1975')
    end

    it 'returns a humanized approximate season string' do
      expect(EDTF.parse!('1975-22~').humanize).to eq('circa summer 1975')
    end

    it 'returns a humanized uncertain and approximate season string' do
      expect(EDTF.parse!('1975-22?~').humanize).to eq('circa summer 1975?')
    end

    it 'returns a humanized southern hemisphere season string' do
      expect(EDTF.parse!('2001-21^southern').humanize).to eq('spring 2001')
    end

    it 'returns a humanized northern hemisphere season string', :edtf5 do
      expect(EDTF.parse!('2001-25').humanize).to eq('spring 2001')
    end

    it 'returns a humanized southern hemisphere winter string', :edtf5 do
      expect(EDTF.parse!('2001-32').humanize).to eq('winter 2001')
    end

    it 'returns the months of a quarter', :edtf5 do
      expect(EDTF.parse!('2001-33').humanize).to eq('January 2001 to March 2001')
    end

    it 'returns the months of a semester', :edtf5 do
      expect(EDTF.parse!('2001-41').humanize).to eq('July 2001 to December 2001')
    end
  end

  context 'with a set' do
    it 'returns a humanized exclusive set string' do
      expect(EDTF.parse!('[1980, 1981, 1983]').humanize).to(
        eq('1980, 1981 or 1983')
      )
    end

    it 'returns a humanized inclusive set string' do
      expect(EDTF.parse!('{1980, 1981, 1983}').humanize).to(
        eq('1980, 1981 and 1983')
      )
    end

    it 'returns a humanized open (before) exclusive set string' do
      expect(EDTF.parse!('[..1980]').humanize).to eq('on or before 1980')
    end

    it 'returns a humanized open (after) exclusive set string' do
      expect(EDTF.parse!('[1980..]').humanize).to eq('on or after 1980')
    end

    it 'returns a humanized open (before) inclusive set string' do
      expect(EDTF.parse!('{..1980}').humanize).to eq('on and before 1980')
    end

    it 'returns a humanized open (after) inclusive set string' do
      expect(EDTF.parse!('{1980..}').humanize).to eq('on and after 1980')
    end
  end

  context 'with an unknown value' do
    it 'returns a humanized unknown string' do
      expect(EDTF.parse!('XXXX').humanize).to eq('unknown')
    end
  end
end
