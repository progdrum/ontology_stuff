(import
  requests
  bs4 [BeautifulSoup])
(require
  hyrule.let [let]
  hyrule.collections [assoc])


(setv drumheads-p1 (requests.get "https://drumheadauthority.com/drumhead-selector")
      bs (BeautifulSoup (. drumheads-p1 text) "html.parser"))

(defn retrieve-names-urls [soup]
  "Retrieve the names of the drum heads for all the items on the page."
  (let [names (lfor
                item
                (soup.find-all "li")
                :if (item.find "h2")
                (. (item.find "h2") text))
        urls (lfor
               item
               (soup.find-all "li")
               :if (item.find "h2")
               (.get (item.find "a") "href"))]
    (dict
      (lfor
        pair
        (zip names urls)
        (list pair)))))

(retrieve-names-urls bs)

;; Retrieve the info table from a specific head's page.
(setv hi-energy (requests.get "https://drumheadauthority.com/product/aquarian-hi-energy-clear-drumhead/")
      bs2 (BeautifulSoup (. hi-energy text) "html.parser"))

(defn retrieve-attributes [soup]
  (let [attr-table (soup.find "table")
        tr-lst (attr-table.find-all "tr")]
    ; TODO: Add function to break up attributes with more than one value!
    (dfor tr
          tr-lst
          [(. (tr.find "th") text)
           (.rstrip (. (tr.find "td") text))])))

(defn get-name-attr-pairs [url-nm]
  "Retrieve the attributes for each head and return in a dict with the names 
   as values. Takes dict of name/url pairs."
  (let [name-attrs {}]
    (for [(, k v) (url-nm.items)]
      (let [drumhead-soup (BeautifulSoup (. (requests.get v) text) "html.parser")]
        (assoc name-attrs k (retrieve-attributes drumhead-soup))))
    name-attrs))

