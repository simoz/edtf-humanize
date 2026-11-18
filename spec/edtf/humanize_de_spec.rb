# frozen_string_literal: true

require 'edtf-humanize'

RSpec.describe Edtf::Humanize do
  before do
    I18n.locale = :de
  end

  it { is_expected.to be_a(Module) }

  context 'with a decade' do
    it 'returns a humanized decade string' do
      expect(EDTF.parse!('199x').humanize).to eq('1990er Jahre')
    end

    it 'returns a humanized BC decade string', :edtf4_or_earlier do
      expect(EDTF::Decade.new(-10).humanize).to eq('10er Jahre v. Chr.')
    end
  end

  context 'with a century' do
    it 'returns a humanized century string' do
      expect(EDTF.parse!('19xx').humanize).to eq('20. Jahrhundert')
    end

    it 'returns a humanized BC century string', :edtf4_or_earlier do
      expect(EDTF::Century.new(-100).humanize).to eq('2. Jahrhundert v. Chr.')
    end
  end

  context 'with an interval' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/1980').humanize).to eq('1970 - 1980')
    end

    # edtf 5 reads 197X and 19XX as a decade and a century unless told
    # otherwise; edtf 3 and 4 ignore the option
    it 'returns a humanized interval string with unspecified decades' do
      expect(EDTF.parse!('198X/199X', centuries: false).humanize).to(
        eq('1980er Jahre (Jahr unbekannt) - 1990er Jahre (Jahr unbekannt)')
      )
    end

    it 'returns a humanized interval string with unspecified centuries' do
      expect(EDTF.parse!('19XX/20XX', centuries: false).humanize).to(
        eq('20. Jahrhundert (Jahr unbekannt) - 21. Jahrhundert (Jahr unbekannt)')
      )
    end
  end

  context 'with an open interval' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/open').humanize).to eq('1970 - ')
    end
  end

  context 'with an unknown interval start' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('unknown/1970').humanize).to eq('unbekanntes Datum bis 1970')
    end
  end

  context 'with an unknown interval end' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/unknown').humanize).to eq('1970 bis unbekanntes Datum')
    end
  end

  context 'with an approximate interval'
  it 'returns a humanized approximate interval string' do
    expect(EDTF.parse!('1970~/1980~').humanize).to(
      eq('circa 1970 - circa 1980')
    )
  end

  context 'with an iso date' do
    it 'returns a humanized ISO date string' do
      expect(EDTF.parse!('1975-07-01').humanize).to eq('1. Juli 1975')
    end
  end

  context 'with an uncertain iso date' do
    it 'returns a humanized uncertain ISO date string' do
      expect(EDTF.parse!('1975?').humanize).to eq('1975 ?')
    end
  end

  context 'with an unspecified year iso date' do
    it 'returns a humanized unspecified year ISO date string' do
      expect(EDTF.parse!('197X', centuries: false).humanize).to eq('1970er Jahre (Jahr unbekannt)')
    end

    it 'returns a humanized unspecified year in a century string' do
      expect(EDTF.parse!('19XX', centuries: false).humanize).to eq('20. Jahrhundert (Jahr unbekannt)')
    end

    it 'returns a humanized unspecified year string with month precision' do
      expect(EDTF.parse!('198X-05').humanize).to eq('Mai 1980er Jahre (Jahr unbekannt)')
    end

    it 'returns a humanized unspecified year string for negative years' do
      expect(EDTF.parse!('-01XX').humanize).to eq('2. Jahrhundert v. Chr. (Jahr unbekannt)')
    end
  end

  context 'with an unspecified month or day' do
    it 'returns a humanized string with an unspecified month' do
      expect(EDTF.parse!('1990-XX').humanize).to eq('1990 (Monat unbekannt)')
    end

    it 'returns a humanized string with an unspecified month and day' do
      expect(EDTF.parse!('1990-XX-XX').humanize).to eq('1990 (genaues Datum unbekannt)')
    end
  end

  context 'with a season' do
    it 'returns a humanized season string' do
      expect(EDTF.parse!('1975-22').humanize).to eq('Sommer 1975')
    end

    it 'returns a humanized approximate season string' do
      expect(EDTF.parse!('1975-22~').humanize).to eq('circa Sommer 1975')
    end

    it 'returns a humanized uncertain and approximate season string' do
      expect(EDTF.parse!('1975-22?~').humanize).to eq('circa Sommer 1975 ?')
    end
  end

  context 'with a set' do
    it 'returns a humanized exclusive set string' do
      expect(EDTF.parse!('[1980, 1981, 1983]').humanize).to(
        eq('1980, 1981 oder 1983')
      )
    end

    it 'returns a humanized inclusive set string' do
      expect(EDTF.parse!('{1980, 1981, 1983}').humanize).to(
        eq('1980, 1981 und 1983')
      )
    end

    it 'returns a humanized open (before) exclusive set string' do
      expect(EDTF.parse!('[..1980]').humanize).to(
        eq('vor 1980')
      )
    end

    it 'returns a humanized open (after) exclusive set string' do
      expect(EDTF.parse!('[1980..]').humanize).to(
        eq('nach 1980')
      )
    end

    it 'returns a humanized open (before) inclusive set string' do
      expect(EDTF.parse!('{..1980}').humanize).to(
        eq('vor 1980')
      )
    end

    it 'returns a humanized open (after) inclusive set string' do
      expect(EDTF.parse!('{1980..}').humanize).to(
        eq('nach 1980')
      )
    end
  end

  context 'with an unknown value' do
    it 'returns a humanized unknown string' do
      expect(EDTF.parse!('XXXX').humanize).to eq('Datum unbekannt')
    end
  end
end
