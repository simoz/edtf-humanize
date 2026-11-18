# frozen_string_literal: true

require 'edtf-humanize'

RSpec.describe Edtf::Humanize do
  before do
    I18n.locale = :fr
  end

  it { is_expected.to be_a(Module) }

  context 'with a decade' do
    it 'returns a humanized decade string' do
      expect(EDTF.parse!('199x').humanize).to eq('Les années 1990')
    end

    it 'returns a humanized BC decade string', :edtf4_or_earlier do
      expect(EDTF::Decade.new(-10).humanize).to eq('Les années 10 avant J.C.')
    end
  end

  context 'with a century' do
    it 'returns a humanized century string' do
      expect(EDTF.parse!('19xx').humanize).to eq('XXe siècle')
    end
  end

  context 'with an interval' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/1980').humanize).to eq('De 1970 à 1980')
    end

    # edtf 5 reads 197X and 19XX as a decade and a century unless told
    # otherwise; edtf 3 and 4 ignore the option
    it 'returns a humanized interval string with unspecified decades' do
      expect(EDTF.parse!('198X/199X', centuries: false).humanize).to(
        eq('Des années 1980 (année inconnue) aux années 1990 (année inconnue)')
      )
    end

    it 'returns a humanized interval string with unspecified centuries' do
      expect(EDTF.parse!('19XX/20XX', centuries: false).humanize).to(
        eq('Du XXe siècle (année inconnue) au XXIe siècle (année inconnue)')
      )
    end

    it 'returns a humanized interval string with unspecified a year and a decade' do
      expect(EDTF.parse!('1985/199X', centuries: false).humanize).to eq('De 1985 aux années 1990 (année inconnue)')
    end

    it 'returns a humanized interval string with unspecified a decade and a year' do
      expect(EDTF.parse!('198X/1995', centuries: false).humanize).to eq('Des années 1980 (année inconnue) à 1995')
    end
  end

  context 'with decades and centuries as edtf 5 reads them', :edtf5 do
    it 'returns a humanized interval string between decades' do
      expect(EDTF.parse!('198X/199X').humanize).to eq('Des années 1980 aux années 1990')
    end

    it 'returns a humanized interval string between centuries' do
      expect(EDTF.parse!('19XX/20XX').humanize).to eq('Du XXe siècle au XXIe siècle')
    end
  end

  context 'with an open interval' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/open').humanize).to eq('Depuis 1970')
    end
  end

  context 'with an unknown interval start' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('unknown/1970').humanize).to eq("date inconnue jusqu'en 1970")
    end
  end

  context 'with an unknown interval end' do
    it 'returns a humanized interval string' do
      expect(EDTF.parse!('1970/unknown').humanize).to eq('1970 à date inconnue')
    end
  end

  context 'with an approximate interval'
  it 'returns a humanized approximate interval string' do
    expect(EDTF.parse!('1970~/1980~').humanize).to(
      eq('De 1970 environ à 1980 environ')
    )
  end

  context 'with an iso date' do
    it 'returns a humanized ISO date string' do
      expect(EDTF.parse!('1975-07-01').humanize).to eq('1 Juillet 1975')
    end
  end

  context 'with an uncertain iso date' do
    it 'returns a humanized uncertain ISO date string' do
      expect(EDTF.parse!('1975?').humanize).to eq('1975?')
    end
  end

  context 'with an unspecified year iso date' do
    it 'returns a humanized unspecified year ISO date string' do
      expect(EDTF.parse!('197X', centuries: false).humanize).to eq('Les années 1970 (année inconnue)')
    end

    it 'returns a humanized unspecified year in a century string' do
      expect(EDTF.parse!('19XX', centuries: false).humanize).to eq('XXe siècle (année inconnue)')
    end

    it 'returns a humanized unspecified year string with month precision' do
      expect(EDTF.parse!('198X-05').humanize).to eq('Mai Les années 1980 (année inconnue)')
    end

    it 'returns a humanized unspecified year string for negative years' do
      expect(EDTF.parse!('-01XX').humanize).to eq('IIe siècle avant J.C. (année inconnue)')
    end
  end

  context 'with an unspecified month or day' do
    it 'returns a humanized string with an unspecified month' do
      expect(EDTF.parse!('1990-XX').humanize).to eq('1990 (mois inconnu)')
    end

    it 'returns a humanized string with an unspecified month and day' do
      expect(EDTF.parse!('1990-XX-XX').humanize).to eq('1990 (date exacte inconnue)')
    end
  end

  context 'with a season' do
    it 'returns a humanized season string' do
      expect(EDTF.parse!('1975-22').humanize).to eq('été 1975')
    end

    it 'returns a humanized approximate season string' do
      expect(EDTF.parse!('1975-22~').humanize).to eq('été 1975 environ')
    end

    it 'returns a humanized uncertain and approximate season string' do
      expect(EDTF.parse!('1975-22?~').humanize).to eq('été 1975 environ?')
    end
  end

  context 'with a set' do
    it 'returns a humanized exclusive set string' do
      expect(EDTF.parse!('[1980, 1981, 1983]').humanize).to(
        eq('1980, 1981 ou 1983')
      )
    end

    it 'returns a humanized inclusive set string' do
      expect(EDTF.parse!('{1980, 1981, 1983}').humanize).to(
        eq('1980, 1981 et 1983')
      )
    end

    it 'returns a humanized open (before) exclusive set string' do
      expect(EDTF.parse!('[..1980]').humanize).to(
        eq('Le ou avant 1980')
      )
    end

    it 'returns a humanized open (after) exclusive set string' do
      expect(EDTF.parse!('[1980..]').humanize).to(
        eq('Le ou après 1980')
      )
    end

    it 'returns a humanized open (before) inclusive set string' do
      expect(EDTF.parse!('{..1980}').humanize).to(
        eq('Le et avant 1980')
      )
    end

    it 'returns a humanized open (after) inclusive set string' do
      expect(EDTF.parse!('{1980..}').humanize).to(
        eq('Le et après 1980')
      )
    end
  end

  context 'with an unknown value' do
    it 'returns a humanized unknown string' do
      expect(EDTF.parse!('XXXX').humanize).to eq('Inconnue')
    end
  end
end
