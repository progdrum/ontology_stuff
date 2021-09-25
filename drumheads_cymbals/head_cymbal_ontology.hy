(import owlready2 *)

(setv onto (get-ontology "https://progdrum.github.io/drumheads_cymbals.owl#"))

(defn get-default [dictionary key [default None]]
    "Like `get`, but with a default if key is not present."
    (try
      (get dictionary key)
      (except [KeyError]
        default)))

;; Macro for defining entities with all options in one command
(defmacro defentity [ent-name parent [attributes {}]]
  (import hy.models [Symbol])
  `(defclass ~(Symbol ent-name) [~(Symbol parent)]
     (setv equivalent-to (get-default ~attributes ':equivalent-to None)
           label (get-default ~attributes ':label [])
           comment (get-default ~attributes ':comments [])
           seeAlso (get-default ~attributes ':see-also [])
           versionInfo (get-default ~attributes ':version-info [])
           deprecated (get-default ~attributes ':is-deprecated [])
           incompatibleWith (get-default ~attributes ':incompatible-with [])
           backwardCompatibleWith (get-default ~attributes ':backward-compatible-with [])
           isDefinedBy (get-default ~attributes ':is-defined-by []))))

;; Lay out the drumhead-related classes
(with [onto]

  (defentity "StruckObject" "Thing"
    {:comments ["Objects that are struck."
                "Parent class of all struck objects."]
     :version-info ["0.1"]})

  (defentity "Drumhead" "StruckObject"
    {:comments ["Generic drumhead class"]
     :version-info ["0.1"]})

  (defclass is-snare-side [(>> Drumhead bool) FunctionalProperty])
  (defclass has-plies [(>> Drumhead int) FunctionalProperty])
  (defclass has-thickness [(>> Drumhead float) FunctionalProperty])

  (defentity "Surface" "Thing"
    {:comments ["Drum heads can have a variety of surfaces that affect the feel, attack, and tone."]
     :version-info ["0.1"]})
  (defentity "Coated" "Surface"
    {:comments ["Coated surfaces are good for brush players."
                "Coated surfaces give a bit warmer tone."]
     :version-info ["0.1"]})
  (defentity "Clear" "Surface"
    {:comments ["Clear heads are a bit brighter and have more attack than coated heads."
                "Clear heads are not so good for playing with brushes."]
     :version-info ["0.1"]})
  (defentity "Suede" "Surface"
    {:version-info ["0.1"]})
  (defentity "Ebony" "Surface"
    {:version-info ["0.1"]})
  (defentity "SimulatedSkin" "Surface"
    {:comments ["These heads attempt to replicate the appearance, feel, and tone of skin drum heads of old."]
     :version-info ["0.1"]})
  (defentity "Frosted" "Surface"
    {:version-info ["0.1"]})
  (defentity "Hazy" "Surface"
    {:comments ["These drum heads have a hazy coating and lie between clear and coated heads sonically."]
     :version-info ["0.1"]})
  (defentity "Etched" "Surface"
    {:version-info ["0.1"]})
  (AllDisjoint [Coated Clear Suede Ebony SimulatedSkin Frosted Hazy Etched])

  (defclass has-surface [(>> Drumhead Surface) FunctionalProperty])
  (defclass is-surface-of [(>> Surface Drumhead) InverseFunctionalProperty]
    (setv inverse-property has-surface))
  
  (defentity "Dampening" "Thing"
    {:comments ["Dampening mechanisms help to reduce unwanted overtones."
                "Too much dampening can deaden the sound of the drum."]
     :version-info ["0.1"]})
  (defentity "InlayRing" "Dampening"
    {:comments ["These are plastic rings, usually underneath the head."]
     :version-info ["0.1"]})
  (defentity "Dot" "Dampening"
    {:comments ["An additional ply in the middle of the head that is smaller in diameter than the head."]
     :version-info ["0.1"]})
  (defentity "CenterDot" "Dot"
    {:version-info ["0.1"]})
  (defentity "ReverseDot" "Dot"
    {:version-info ["0.1"]})
  (defentity "Holes" "Dampening"
    {:comments ["Holes allow additional air to escape upon striking."]
     :version-info ["0.1"]})
  (defentity "Ring" "Dampening"
    {:version-info ["0.1"]})
  (defentity "Oil" "Dampening"
    {:comments ["Requires at least two plies."]
     :version-info ["0.1"]})

  (defclass has-dampening [(>> Drumhead Dampening)])
  (defclass is-dampening-for [(>> Dampening Drumhead) InverseFunctionalProperty]
    (setv inverse-property has-dampening))
  (defclass dot-thickness [(>> Dot float) FunctionalProperty])

  (defentity "Manufacturer" "Thing"
    {:version-info ["0.1"]})
  (defentity "Remo" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Evans" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Aquarian" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Other" "Manufacturer"
    {:version-info ["0.1"]})
  (AllDisjoint [Remo Evans Aquarian Other])

  (defclass has-manufacturer [(>> StruckObject Manufacturer) FunctionalProperty])
  (defclass is-manufacturer-of [(>> Manufacturer StruckObject)]
    (setv inverse-property has-manufacturer)))

;; Lay out the cymbal-related classes
(with [onto]

  (defentity "Cymbal" "StruckObject"
    {:comments ["Generic cymbal class"]
     :version-info ["0.1"]})
  (defentity "Crash" "Cymbal"
    {:comments ["May also be rideable"]
     :version-info ["0.1"]})
  (defentity "Ride" "Cymbal"
    {:comments ["May also be crashable."]
     :see-also ["Crash"]
     :version-info ["0.1"]})
  (defentity "FlatRide" "Ride"
    {:comments ["Ride cymbals without a pronounced bell"]
     :version-info ["0.1"]})
  (defentity "CrashRide" "Cymbal"
    {:equivalent-to [(& Crash Ride)]
     :comments ["A cymbal made for both crashing and riding"]})
  (defentity "Splash" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "HiHat" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "China" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "Efx" "Cymbal"
    {:comments ["Miscellaneous effects cymbals"]
     :version-info ["0.1"]})
  (defentity "Gong" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "TamTam" "Gong"
    {:version-info ["0.1"]})
  (defentity "NippleGong" "Gong"
    {:version-info ["0.1"]})
  (AllDisjoint [Crash HiHat China Gong])
  (AllDisjoint [Ride HiHat China Gong])

  (defentity "Alloy" "Thing"
    {:comments ["Different grades of brass and bronze yield different quality cymbals and gongs."
                "The bronze or brass alloy from which a cymbal is made"]
     :version-info ["0.1"]})
  (defentity "Brass" "Alloy"
    {:comments ["Typically cheap cymbals that come with beginner drum kits."]
     :version-info ["0.1"]})
  (defentity "B8" "Alloy"
    {:comments ["Commonly used for beginner/intermediate-level cymbals"
                "B8 alloy (92% copper, 8% tin)"]
     :version-info ["0.1"]})
  (defentity "B10" "Alloy"
    {:comments ["Intermediate-grade cymbals, typically"
                "B10 alloy (90% copper, 10% tin)"]
     :version-info ["0.1"]})
  (defentity "B20" "Alloy"
    {:comments ["Usually top-of-the-line cymbals"
                "B20 alloy (80% copper, 20% tin)"]
     :version-info ["0.1"]})
  (AllDisjoint [Brass B8 B10 B20])

  (defclass is-made-of [(>> Cymbal Alloy) FunctionalProperty])
  (defclass has-weight [(>> Cymbal str) FunctionalProperty])
  (defclass is-lathed [(>> Cymbal bool)])
  (defclass has-hybrid-lathing [(>> Cymbal bool) FunctionalProperty])
  
  (defentity "Bosphorus" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Istanbul" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Dream" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Meinl" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Sabian" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Zildjian" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Paiste" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Wuhan" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Stagg" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Other" "Manufacturer"
    {:version-info ["0.1"]})
  (AllDisjoint [Bosphorus Istanbul Dream Meinl Sabian Zildjian Paiste Wuhan Stagg Other]))

;; Add some other classes that combine classes and properties
(with [onto]

  (defentity "ThickHead" "Drumhead"
    {:equivalent-to [(& Drumhead (|
                                   (>= has-thickness 12)
                                   (>= has-plies 2)))]
     :version-info ["0.1"]})

  (defentity "ThinHead" "Drumhead"
    {:equivalent-to (& Drumhead
                       (<= has-thickness 11))
     :version-info ["0.1"]}))


;; Create some drum head instances
(setv remo-emperor-clear (Drumhead
                           "Emperor"
                           :has-plies 2
                           :has-thickness 14
                           :has-surface (Clear)
                           :has-manufacturer (Remo))
      aquarian-triple-threat (Drumhead
                               "Triple_Threat"
                               :has-plies 3
                               :has-thickness 21
                               :has-surface (Coated)
                               :has-manufacturer (Aquarian))
      evans-eq4-frosted (Drumhead
                          "EQ4_Frosted"
                          :has-plies 1
                          :has-thickness 10
                          :has-surface (Frosted)
                          :has-dampening [(Ring)]
                          :has-manufacturer (Evans)))

;; Create some cymbal instances
(setv meinl-byzance-dark-ride (Cymbal
                                "Byzance_Dark_Ride"
                                :is-made-of (B20)
                                :has-weight "Medium_Thin"
                                :is-lathed [False]
                                :has-manufacturer (Meinl))
      wuhan-large-china (Cymbal
                          "20_inch_China"
                          :is-made-of (B20)
                          :has-weight "Thin"
                          :is-lathed [True]
                          :has-manufacturer (Wuhan)))

;; Generate inferences, including those for property values
(with [onto]
  (sync-reasoner :infer-property-values True))

;; Try some test queries

; What products does Wuhan manufacture?
(. onto wuhan1 is-manufacturer-of)

; What drum heads are thick heads?
(ThickHead.instances)

;; Save the ontology to a file
(onto.save "test_ontologies/drums_cymbals.owl")

