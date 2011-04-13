module Ankusa

  class NaiveBayesClassifier
    include Classifier

    def classify(text, classes=nil)
      # return the most probable class
      log_likelihoods(text, classes).sort_by { |c| -c[1] }.first.first
    end
    
    # Classes is an array of classes to look at
    def classifications(text, classnames=nil)
      result = log_likelihoods text, classnames
      result.keys.each { |k|
        result[k] = Math.exp result[k] 
      }

      # normalize to get probs
      sum = result.values.inject { |x,y| x+y }
      result.keys.each { |k| result[k] = result[k] / sum }
      result
    end

    # Classes is an array of classes to look at
    def log_likelihoods(text, classnames=nil)
      classnames ||= @classnames
      result = Hash.new 0

      TextHash.new(text).each { |word, count|
        probs = get_word_probs(word, classnames)
        classnames.each { |k| 
			result[k] += (Math.log(probs[k]) * count) unless probs[k] < 1
			result[k] += count if probs[k] < 1
		}
      }

      # add the prior and exponentiate
      doc_counts = doc_count_totals.select { |k,v| classnames.include? k }.map { |k,v| v }
      doc_count_total = (doc_counts.inject { |x,y| x+y } + classnames.length).to_f
      classnames.each { |k| 
        result[k] += Math.log((@storage.get_doc_count(k) + 1).to_f / doc_count_total) 
      }
      
      result
    end

  end

end
