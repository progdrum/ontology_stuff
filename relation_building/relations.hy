(import spacy)
(require hyrule.let [let])
(import hyrule.iterables [flatten])


(setv nlp (spacy.load "en_core_web_sm"))

;; Test sentences
(setv sent1 "London is the capital of England."
      sent2 "London is a major settlement.")

;; Categories for building relations
(setv constructions ["compound" "conj" "mod" "prep"]
      relations ["ROOT" "attr" "amod" "adj" "agent"])

(defn create-triple [sentence]
  "Create a triple representing a relation from a sentence."
  (let [subj []
        rel []
        obj []
        subj-con []
        obj-con []
        doc (nlp sentence)]
    (for [token doc]
      (let [dep (. token dep_)]
        (cond [(in "subj" dep) (do
                                 (subj.append subj-con)
                                 (subj.append (. token text)))]
              [(in "obj" dep) (do
                                (obj.append obj-con)
                                (obj.append (. token text)))]
              ;; [(in dep constructions) (cond [(not subj) (subj-con.append (. token text))]
              ;;                               [True (obj-con.append (. token text))])]
              [(in dep relations) (rel.append (. token lemma_))])))
    (print (, (.join " " (flatten subj))
              (.join " " (flatten rel))
              (.join " " (flatten obj))))))

(create-triple sent1)
(create-triple sent2)

