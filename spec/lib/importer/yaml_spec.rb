# Copyright 2013 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# encoding: UTF-8
require 'spec_helper'

describe Importer::Yaml do
  context "[importing]" do
    before :all do
      Project.where(repository_url: Rails.root.join('spec', 'fixtures', 'repository.git').to_s).delete_all
      @project = FactoryGirl.create(:project,
                                    repository_url: Rails.root.join('spec', 'fixtures', 'repository.git').to_s,
                                    only_paths:     %w(config/locales/),
                                    skip_imports:   Importer::Base.implementations.map(&:ident) - %w(yaml))
      @commit  = @project.commit!('HEAD')
    end

    it "should import strings from YAML files" do
      @project.keys.for_key('root').first.translations.find_by_rfc5646_locale('en-US').copy.should eql('root')
      @project.keys.for_key('nested.one').first.translations.find_by_rfc5646_locale('en-US').copy.should eql('one')
      @project.keys.for_key('nested.2').first.translations.find_by_rfc5646_locale('en-US').copy.should eql('two')
    end

    it "should import string arrays" do
      @project.keys.for_key('abbr_month_names[2]').first.translations.find_by_rfc5646_locale('en-US').copy.should eql('Feb')
      @project.keys.for_key('abbr_month_names[12]').first.translations.find_by_rfc5646_locale('en-US').copy.should eql('Dec')
    end
  end
end
