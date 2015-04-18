module Porse
  describe 'Crawler' do
    let(:crawler) { Crawler.new }

    describe '#initialize' do
      it 'setups agent for future use' do
        expect(crawler.agent).to be_kind_of(Mechanize)
      end
    end

    describe '#process' do
      let(:urls) { ['http://google.com', 'http://ya.ru', 'http://tut.by'] }
      let(:block) { ->(x) {} }
      let(:pages) do
        urls.map { |url| double(:page, :body => 'Page Body' + url) }
      end

      it 'configures itself before processing' do
        expect(crawler).to receive(:configure).with(urls, {})

        crawler.process(urls, &block)
      end

      it 'opens every url' do
        allow(crawler).to receive(:open).and_return(*pages)

        urls.each { |url| expect(crawler).to receive(:open).with(url) }

        crawler.process(urls, &block)
      end

      it 'yields once per every url, passing page' do
        allow(crawler).to receive(:open).and_return(*pages)

        expect { |b| crawler.process(urls, &b) }.to yield_successive_args(*pages)
      end

      it 'stops iterating if current page body is equal to previous one' do
        allow(pages[-1]).to receive(:body).and_return(pages[-2].body)
        allow(crawler).to receive(:open).and_return(*pages)

        expect { |b| crawler.process(urls, &b) }.to yield_control.exactly(pages.count - 1).times
      end
    end

    describe '#open' do
      let(:url) { 'http://google.com' }
      let(:page) { 'page' }

      it 'relies on agent to open pages' do
        expect(crawler.agent).to receive(:get).with(url).and_return(page)

        crawler.open(url)
      end
    end

    describe '#configure' do
      it 'opens a homepage before processing if homepage cookies setting is present' do
        crawler.settings[:homepage_cookies] = true
        urls = ['http://google.com/?q=1', 'http://google.com/?q=asdfasfa']

        allow(crawler).to receive(:open).and_return(double(:page, :body => 'Page Body'))

        expect(crawler).to receive(:open).with('http://google.com').ordered
        expect(crawler).to receive(:open).with(urls.first).ordered
        expect(crawler).to receive(:open).with(urls.last).ordered

        crawler.process(urls) {}
      end
    end
  end
end
