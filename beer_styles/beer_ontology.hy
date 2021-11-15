(import json
        types
        pandas [json-normalize]
        owlready2 *
        hy.models [Symbol])
(require hyrule.let [let]
         hyrule [assoc])


(with [f (open "styleguide-2015.json")]
  (setv style-data (json.load f)))

(setv all-categories []
      categories (get style-data "styleguide" "class" 0 "category"))

;; Break down each of the categories and sub-categories
(for [category categories]
  (for [sub-category (get category "subcategory")]
    (setv (get sub-category "parent") category)
    (all-categories.append sub-category)))

(setv styles (json-normalize all-categories))

;; Set up any special categories that may be in the data
(setv (get styles "special_category")
      (.apply (get styles "name")
              (fn [nm]
                (let [splits (nm.split ": ")]
                  (if (> (len splits) 1)
                      (get splits 0)
                      "")))))

;; Clean up the names with special categories
(setv (get styles "name")
      (.apply (get styles "name")
              (fn [nm]
                (let [splits (nm.split ": ")]
                  (if (> (len splits) 1)
                      (get splits 1)
                      (get splits 0))))))

(setv beer-onto (get-ontology "https://progdrum.github.io/beer_onto.owl#"))

(with [beer-onto]

  ;; Define some base classes/entities
  (defclass Beer [Thing])
  (defclass Ale [Beer])
  (defclass Lager [Beer])
  (defclass Hops [Thing])
  (defclass Malt [Thing])
  (defclass Characteristic [Thing])
  (defclass Flavor [Characteristic])
  (defclass Appearance [Characteristic])
  (defclass Impression [Characteristic])
  (defclass Aroma [Characteristic])
  (defclass Mouthfeel [Characteristic])
  (defclass Strength [Characteristic])
  (defclass Style [Characteristic])
  (defclass Family [Characteristic])
  (defclass Location [Thing])
  (AllDisjoint [Beer Hops Malt Flavor Appearance Strength Style Family Location])

  ;; Define some initial properties
  (defclass has-flavor [(>> Beer Flavor)])
  (defclass has-hops [(>> Beer Hops)])
  (defclass hop-appears-in [(>> Hops Beer)]
    (setv inverse-property-of has-hops))
  (defclass has-malt [(>> Beer Malt)])
  (defclass malt-appears-in [(>> Malt Beer)]
    (setv inverse-property-of has-malt))
  (defclass has-appearance [(>> Beer Appearance)])
  (defclass has-strength [(>> Beer Strength)])
  (defclass is-style [(>> Beer Style) FunctionalProperty])
  (defclass is-from [(>> Beer Location) FunctionalProperty])
  (defclass produces-beers [(>> Location Beer)]
    (setv inverse-property-of is-from))
  (defclass in-family [(>> Beer Family) FunctionalProperty])
  (defclass has-parent [(>> Beer Beer) FunctionalProperty])
  (defclass is-parent-of [(>> Beer Beer)]
    (setv inverse-property-of has-parent))
  (defclass has-min-abv [(>> Beer float) FunctionalProperty])
  (defclass has-max-abv [(>> Beer float) FunctionalProperty])
  (defclass has-min-srm [(>> Beer float) FunctionalProperty])
  (defclass has-max-srm [(>> Beer float) FunctionalProperty])
  (defclass has-min-og [(>> Beer float) FunctionalProperty])
  (defclass has-max-og [(>> Beer float) FunctionalProperty])
  (defclass has-min-fg [(>> Beer float) FunctionalProperty])
  (defclass has-max-fg [(>> Beer float) FunctionalProperty])
  (defclass has-min-ibu [(>> Beer float) FunctionalProperty])
  (defclass has-max-ibu [(>> Beer float) FunctionalProperty])

  (let [parent-styles (.to-dict
                        (get styles ["parent.name" "parent.notes" "parent.subcategory"])
                        :orient "records")
        child-styles (.to-dict (get styles ["name" "parent.name"]) :orient "records")]
    ;; Add the parent categories (need to add some class attributes at some point?)
    (let [unique-dict {} inner-dict {}]
      (for [record parent-styles]
        (assoc inner-dict
               "notes" (get record "parent.notes")
               "subcategory" (get record "parent.subcategory"))
        (assoc unique-dict (get record "parent.name") inner-dict))
      ;; Right now, I'm just getting the names. I'll want to add the other attributes later.
      (for [pstyle (unique-dict.keys)]
        (types.new-class pstyle (, Beer))))

    ;; Add the child beer styles definitely need to add some class attributes at some point!
    (for [cstyle child-styles]
      (types.new-class (.replace (get cstyle "name") " " "")
                       (, (get beer-onto (get cstyle "parent.name")))))))

