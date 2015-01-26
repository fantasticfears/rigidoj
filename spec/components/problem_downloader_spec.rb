require 'spec_helper'

describe ProblemDownloader do
  let(:available_judge_strategies) { %w(hdu poj uva uva_live zoj) }
  it 'initialze' do
    available_judge_strategies.each do |name|
      expect { ProblemDownloader.new(name, 0) }.not_to raise_error
    end
  end

  it 'raises error when online judge strategy is not available' do
    %w(a b).each do |name|
      expect { ProblemDownloader.new(name, 0) }.to raise_error(ProblemDownloader::NoDownloadStrategy)
    end
  end

  describe 'ProblemDownloader::HDUStrategy downloads problem' do
    before do
      fake('http://acm.hdu.edu.cn/showproblem.php?pid=0', external_oj_response('hdu_not_exists'))
      fake('http://acm.hdu.edu.cn/showproblem.php?pid=1025', external_oj_response('hdu_normal'))
    end

    it 'create nil when the problem is not exists' do
      problem = ProblemDownloader.download_and_create_problem('hdu', 0)
      expect(problem).to be_nil
    end

    it 'downloads and creates valid problem' do
      problem = ProblemDownloader.download_and_create_problem('hdu', 1025)
      expect(problem).not_to be_nil
      expect(problem.valid?).to be_truthy
    end

    it 'should parsed accordingly' do
      problem = ProblemDownloader.download_and_create_problem('hdu', 1025)
      expect(problem.raw).to eq parsed_markdown('hdu_1025')
    end
  end

  describe 'ProblemDownloader::ZOJStrategy downloads problem' do
    before do
      fake('http://acm.zju.edu.cn/onlinejudge/showProblem.do?problemCode=0', external_oj_response('zoj_not_exists'))
      fake('http://acm.zju.edu.cn/onlinejudge/showProblem.do?problemCode=3814', external_oj_response('zoj_normal'))
    end

    it 'create nil when the problem is not exists' do
      problem = ProblemDownloader.download_and_create_problem('zoj', 0)
      expect(problem).to be_nil
    end

    it 'downloads and creates valid problem' do
      problem = ProblemDownloader.download_and_create_problem('zoj', 3814)
      expect(problem).not_to be_nil
      expect(problem.valid?).to be_truthy
    end

    it 'should parsed accordingly' do
      problem = ProblemDownloader.download_and_create_problem('zoj', 3814)
      expect(problem.title).to eq 'Sawtooth Puzzle'
      expect(problem.raw).to eq parsed_markdown('zoj_3814')
    end
  end
end
