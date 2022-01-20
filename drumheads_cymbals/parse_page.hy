(import
  requests
  bs4 [BeautifulSoup]
  multiprocessing.dummy [Pool :as ThreadPool])
(require
  hyrule.let [let]
  hyrule.collections [assoc])


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

(defn retrieve-attributes [soup]
  "Retrieve the drum head attributes from the attributes table."
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

(defn process-page [url]
  "Process a web page, retrieving all the drum head information."
  (let [page (requests.get url)
        bs (BeautifulSoup (. page text) "html.parser")]
    (get-name-attr-pairs drumhead)))

(if (= --name-- "__main__")
    (setv pages
          ["https://drumheadauthority.com/drumhead-selector"
           "https://drumheadauthority.com/drumhead-selector/page/2/"
           "https://drumheadauthority.com/drumhead-selector/page/3/"
           "https://drumheadauthority.com/drumhead-selector/page/4/"
           "https://drumheadauthority.com/drumhead-selector/page/5/"
           "https://drumheadauthority.com/drumhead-selector/page/6/"])

    ;; Process each of the pages in parallel, using as many workers
    ;; as there are pages to process.
    (with [pool (ThreadPool (len pages))]
      (pool.map process-page pages)))

