module Porse
  describe 'UrlGenerator' do
    let(:starting_url) { 'google.com' }
    let(:param_name) { 'p' }
    let(:url_generator) { UrlGenerator.new(starting_url, param_name) }

    describe '#initialize' do
      it 'sets up starting url and name of the parameter' do
        expect(url_generator.starting_url).to eq(starting_url)
        expect(url_generator.param_name).to eq(param_name)
      end

      it 'sets generator to initial state' do
        expect_any_instance_of(UrlGenerator).to receive(:rewind)
        url_generator
      end
    end

    describe '#rewind' do
      it 'sets current uri to parsed starting url' do
        expect(URI).to receive(:parse).with(starting_url).and_call_original
        expect(url_generator.current_uri).to be_kind_of(URI)
      end
    end

    describe '#next_url' do
      it 'returns absolute URL' do
        url = url_generator.next_url
        expect(URI.parse(url).absolute?).to be(true)
      end

      it 'it starts with 1 and increments parameter value' do
        values = 3.times.map do
          url = url_generator.next_url
          value = url.scan(/#{param_name}=([^&]+)/)[0][0].to_i
        end

        expect(values).to be_eql([1,2,3])
      end

      it 'replaces parameter value' do
        urls = 3.times.map { url_generator.next_url }
        urls.last.scan(/#{param_name}=([^&]+)/).count
      end
    end

    describe '#to_enum' do
      let(:enumerator) { url_generator.to_enum }

      it 'returns Enumerator' do
        expect(enumerator).to be_kind_of(Enumerator)
      end

      it 'provides enumerator for next urls' do
        expect(url_generator).to receive(:next_url).exactly(3).times

        enumerator.take(3)
      end

      it 'provides enumerator which can be reset' do
        url = enumerator.take(3).last
        enumerator.rewind
        url_after_reset = enumerator.take(3).last

        expect(url).to eq(url_after_reset)
      end
    end

  end
end
