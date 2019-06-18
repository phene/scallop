require "scallop"

RSpec.describe Scallop do
  describe "#to_command & #cmd & #sudo" do
    specify "command building" do
      expect(Scallop.cmd(:ls).to_command).to eq "ls"
      expect(Scallop.cmd("ls /home/scallop").to_command).to eq "ls /home/scallop"
      expect(Scallop.sudo(:chucknorris).cmd("rm -rf /").to_command).to eq "sudo -u chucknorris rm -rf /"
      expect(Scallop.sudo.cmd("ls").to_command).to eq "sudo ls"
    end
  end

  describe "#run" do
    specify "successful command" do
      result = Scallop.cmd("grep Lorem #{fixture_path('lorem.txt')}").run

      expect(result.stdout).to include("Lorem ipsum")
      expect(result.stderr).to be_empty
      expect(result.success?).to eq true
    end

    specify "failed command without stderr" do
      result = Scallop.cmd("grep bollocks #{fixture_path('lorem.txt')}").run

      expect(result.stdout).to be_empty
      expect(result.stderr).to be_empty
      expect(result.success?).to eq false
    end


    specify "failed command with stderr" do
      result = Scallop.cmd("grep bollocks bollocks.txt").run

      expect(result.stdout).to be_empty
      expect(result.stderr).to include("No such file or directory")
      expect(result.success?).to eq false
    end
  end

  describe "#run!" do
    specify "successful command" do
      result = Scallop.cmd("grep Lorem #{fixture_path('lorem.txt')}").run!

      expect(result.stdout).to include("Lorem ipsum")
      expect(result.stderr).to be_empty
      expect(result.success?).to eq true
    end

    specify "failed command with stderr" do
      expect do
        Scallop.cmd("grep bollocks bollocks.txt").run! 
      end.to raise_error do |error|
        expect(error).to be_a(Scallop::Errors::CommandFailed)
        expect(error).to respond_to(:result)

        expect(error.result.stdout).to be_empty
        expect(error.result.stderr).to include("No such file or directory")
        expect(error.result.success?).to eq false
      end
    end
  end
end
