require_relative '../rails_helper'
require_relative '../../lib/clickhouse/rails/migrations/base'

RSpec.describe Clickhouse::Rails::Migrations::Base do
  describe '.run_up' do
    subject(:run_up) { described_class.run_up }

    include_context 'with init migration' do
      it 'executes up and add version' do
        expect(Init).to receive(:up)
        expect(Init).to receive(:add_version)

        subject
      end

      context 'when two Init in @migrations_list' do
        before do
          described_class.migrations_list << Init
        end

        it 'skips the second time' do
          expect(Init).to receive(:up).once

          subject
        end
      end
    end
  end

  describe '.create_table' do
    subject(:create_table) { described_class.create_table(table_name, &block) }

    let(:config_file) { file_fixture('clickhouse.yml') }
    let(:table_name) { 'example' }
    let(:block) do
      lambda do |t|
        t.string 'field'

        t.engine 'File(TabSeparated)'
      end
    end

    before do
      Clickhouse::Rails.config(config_file.realpath.to_s)
      Clickhouse::Rails.init!
      described_class.soft_drop_table(table_name)
    end

    it 'adds table to clickhouse' do
      create_table

      expect(described_class).to be_table_exists(table_name)
    end
  end

  describe '.alter_table' do
    let(:table_name) { 'custom_table' }
    subject(:alter_table) { described_class.alter_table(table_name, &block) }
    # let(:block) { lambda { fetch_column :new_ids, :uint8 } }
    let(:block) do
      proc do
        described_class.fetch_column :new_ids, :uint8
      end
    end

    before do
      with_table table_name do |t|
        t.date 'date'

        t.engine 'MergeTree(date, date, 8192)'
      end
    end

    it 'adds column to existing table' do
      alter_table
      columns = described_class.connection.describe_table(table_name)
      expect(columns).to eq([
                              ['date', 'Date', '', '', '', ''],
                              ['new_ids', 'UInt8', '', '', '', '']
                            ])
    end
  end

  describe '.add_version' do
    include_context 'with init migration'

    it 'executes up and add version' do
      described_class.add_version

      expect(Clickhouse.connection.count(from: migration_table)).to eq(1)
    end
  end
end
