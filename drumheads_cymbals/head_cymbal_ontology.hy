(import owlready2 *)
(require hyrule.let [let])

(setv onto (get-ontology "https://progdrum.github.io/drumheads_cymbals.owl#"))

(defn get-default [dictionary key [default None]]
    "Like `get`, but with a default if key is not present."
    (try
      (get dictionary key)
      (except [KeyError]
        default)))

;; TODO: Improve on this when unpack-mapping becomes available in macros.
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
                "Parent class of all struck objects."]})

  (defentity "Drumhead" "StruckObject"
    {:comments ["Generic drumhead class"]})

  (defclass is-snare-side [(>> Drumhead bool) FunctionalProperty])
  (defclass has-plies [(>> Drumhead int) FunctionalProperty])
  (defclass has-thickness [(>> Drumhead float) FunctionalProperty])

  (defentity "Surface" "Thing"
    {:comments ["Drum heads can have a variety of surfaces that affect the feel, attack, and tone."]})
  (defentity "Coated" "Surface"
    {:comments ["Coated surfaces are good for brush players."
                "Coated surfaces give a bit warmer tone."]})
  (defentity "Clear" "Surface"
    {:comments ["Clear heads are a bit brighter and have more attack than coated heads."
                "Clear heads are not so good for playing with brushes."]})
  (defentity "Suede" "Surface")
  (defentity "Ebony" "Surface")
  (defentity "SimulatedSkin" "Surface"
    {:comments ["These heads attempt to replicate the appearance, feel, and tone of skin drum heads of old."]})
  (defentity "Frosted" "Surface")
  (defentity "Hazy" "Surface"
    {:comments ["These drum heads have a hazy coating and lie between clear and coated heads sonically."]})
  (defentity "Etched" "Surface")
  (AllDisjoint [Coated Clear Suede Ebony SimulatedSkin Frosted Hazy Etched])

  (defclass has-surface [(>> Drumhead Surface)])
  (defclass is-surface-of [(>> Surface Drumhead)]
    (setv inverse-property has-surface))
  
  (defentity "Dampening" "Thing"
    {:comments ["Dampening mechanisms help to reduce unwanted overtones."
                "Too much dampening can deaden the sound of the drum."]})
  (defentity "InlayRing" "Dampening"
    {:comments ["These are plastic or foam rings, usually underneath the head."]})
  (defentity "RemovableDampening" "Dampening"
    {:comments ["Dampening devices that can be removed from the drum as desired."]})
  (defentity "Dot" "Dampening"
    {:comments ["An additional ply in the middle of the head that is smaller in diameter than the head."]})
  (defentity "CenterDot" "Dot")
  (defentity "ReverseDot" "Dot")
  (defentity "Holes" "Dampening"
    {:comments ["Holes allow additional air to escape upon striking."]})
  (defentity "ControlRing" "Dampening")
  (defentity "Oil" "Dampening"
    {:comments ["Requires at least two plies."]})

  (defclass has-dampening [(>> Drumhead Dampening)])
  (defclass is-dampening-for [(>> Dampening Drumhead)]
    (setv inverse-property has-dampening))
  (defclass dot-thickness [(>> Dot float) FunctionalProperty])

  (defentity "Manufacturer" "Thing")

  (defclass has-manufacturer [(>> StruckObject Manufacturer) FunctionalProperty])
  (defclass is-manufacturer-of [(>> Manufacturer StruckObject)]
    (setv inverse-property has-manufacturer)))

;; Lay out the cymbal-related classes
(with [onto]

  (defentity "Cymbal" "StruckObject"
    {:comments ["Generic cymbal class"]})
  (defentity "Crash" "Cymbal"
    {:comments ["May also be rideable"]})
  (defentity "Ride" "Cymbal"
    {:comments ["May also be crashable."]
     :see-also ["Crash"]})
  (defentity "FlatRide" "Ride"
    {:comments ["Ride cymbals without a pronounced bell"]})
  (defentity "CrashRide" "Cymbal"
    {:equivalent-to [(& Crash Ride)]
     :comments ["A cymbal made for both crashing and riding"]})
  (defentity "Splash" "Cymbal")
  (defentity "HiHat" "Cymbal")
  (defentity "China" "Cymbal")
  (defentity "Efx" "Cymbal"
    {:comments ["Miscellaneous effects cymbals"]})
  (defentity "Gong" "Cymbal")
  (defentity "TamTam" "Gong")
  (defentity "NippleGong" "Gong")
  (defentity "ChauGong" "TamTam")
  (AllDisjoint [Crash HiHat China Gong])
  (AllDisjoint [Ride HiHat China Gong])

  (defentity "Alloy" "Thing"
    {:comments ["Different grades of brass and bronze yield different quality cymbals and gongs."
                "The bronze or brass alloy from which a cymbal is made"]})
  (defentity "Brass" "Alloy"
    {:comments ["Typically cheap cymbals that come with beginner drum kits."]})
  (defentity "B8" "Alloy"
    {:comments ["Commonly used for beginner/intermediate-level cymbals"
                "B8 alloy (92% copper, 8% tin)"]})
  (defentity "B10" "Alloy"
    {:comments ["Intermediate-grade cymbals, typically"
                "B10 alloy (90% copper, 10% tin)"]})
  (defentity "B20" "Alloy"
    {:comments ["Usually top-of-the-line cymbals"
                "B20 alloy (80% copper, 20% tin)"]})
  (AllDisjoint [Brass B8 B10 B20])

  (defentity "Lathing" "Thing")
  (defentity "FullyLathed" "Lathing")
  (defentity "Unlathed" "Lathing")
  (defentity "Hybrid" "Lathing")
  
  (defclass is-made-of [(>> Cymbal Alloy) FunctionalProperty])
  (defclass has-weight [(>> Cymbal str) FunctionalProperty])
  (defclass is-lathed [(>> Cymbal bool)])
  (defclass has-lathing [(>> Cymbal Lathing) FunctionalProperty]))

;;;; Add some other classes to take into account for our attributes

(with [onto]
  ;; Drum types
  (defentity "Drum" "StruckObject"
    {:comments ["A membranophone that is struck to produce music"]})
  (defentity "SnareDrum" "Drum"
    {:comments ["A drum featuring metal wires against the resonant head to produce a crisp note or 'snap'"]})
  (defentity "BassDrum" "Drum"
    {:comments ["A large drum with a low note"]})
  (defentity "TomTom" "Drum"
    {:comments ["Any of a series of snareless drums"]})
  (defentity "Bucket" "Drum"
    {:comments ["Yes, even buckets can be drums."]})

  ;; What kinds of drums does the head go on? Will this work for getting me individuals later?
  (defclass goes-on [(>> Drumhead Drum)])
  (defclass takes-head [(>> Drum Drumhead)]
    (setv inverse-property goes-on))

  ;; Durability
  (defentity "Durability" "Thing")
  (defentity "VeryLowDurability" "Durability")
  (defentity "LowDurability" "Durability")
  (defentity "MediumDurability" "Durability")
  (defentity "HighDurability" "Durability")
  (defentity "VeryHighDurability" "Durability")
  (defentity "ExtremeDurability" "Durability")

  (defclass has-durability [(>> Drumhead Durability) FunctionalProperty])
  (defclass heads-with-durability [(>> Durability Drumhead)]
    (setv inverse-property has-durability))

  ;; Attack
  (defentity "Attack" "Thing")
  (defentity "VeryLowAttack" "Attack")
  (defentity "LowAttack" "Attack")
  (defentity "ModerateAttack" "Attack")
  (defentity "HighAttack" "Attack")
  (defentity "VeryHighAttack" "Attack")

  (defclass has-attack [(>> Drumhead Attack)])
  (defclass heads-with-attack [(>> Attack Drumhead)]
    (setv inverse-property has-attack))

  ;; Overtones
  (defentity "Overtones" "Thing")
  (defentity "VeryLowOvertones" "Overtones")
  (defentity "LowOvertones" "Overtones")
  (defentity "ModerateOvertones" "Overtones")
  (defentity "HighOvertones" "Overtones")
  (defentity "VeryHighOvertones" "Overtones")

  (defclass has-overtones [(>> Drumhead Overtones)])
  (defclass heads-with-overtones [(>> Overtones Drumhead)]
    (setv inverse-property has-overtones))

  ;; Responsiveness
  (defentity "Responsiveness" "Thing")
  (defentity "VeryLowResponsiveness" "Responsiveness")
  (defentity "LowResponsiveness" "Responsiveness")
  (defentity "MediumResponsiveness" "Responsiveness")
  (defentity "HighResponsiveness" "Responsiveness")
  (defentity "VeryHighResponsiveness" "Responsiveness")

  (defclass has-responsiveness [(>> Drumhead Responsiveness) FunctionalProperty])
  (defclass heads-with-responsiveness [(>> Responsiveness Drumhead)]
    (setv inverse-property has-responsiveness))

  ;; Sound
  (defentity "Sound" "Thing")
  (defentity "VeryWarm" "Sound")
  (defentity "Warm" "Sound")
  (defentity "Balanced" "Sound")
  (defentity "Bright" "Sound")
  (defentity "VeryBright" "Sound")

  (defclass has-sound [(>> Drumhead Sound)])
  (defclass heads-with-sound [(>> Sound Drumhead)]
    (setv inverse-property has-sound))

  ;; Sustain
  (defentity "Sustain" "Thing")
  (defentity "VeryLowSustain" "Sustain")
  (defentity "LowSustain" "Sustain")
  (defentity "ModerateSustain" "Sustain")
  (defentity "HighSustain" "Sustain")
  (defentity "VeryHighSustain" "Sustain")

  (defclass has-sustain [(>> Drumhead Sustain)])
  (defclass heads-with-sustain [(>> Sustain Drumhead)]
    (setv inverse-property has-sustain)))

;; Add some other classes that combine classes and properties
(with [onto]

  (defentity "ThickHead" "Drumhead"
    {:equivalent-to [(& Drumhead
                        (|
                          (>= has-thickness 12)
                          (>= has-plies 2)))]})

  (defentity "ThinHead" "Drumhead"
    {:equivalent-to [(& Drumhead
                         (< has-thickness 12))]}))

;;;; Add instances to the ontology, beginning here!

;; Gather the dict for each page into one large dict
(import re
        parse-page
        collections [ChainMap])
(setv drumheads (parse-page.parse-data))
(setv all-heads (ChainMap #*drumheads))

(defn extract-number [val]
  "Given an alphanumeric value, retrieve just the number"
  (let [num-val (if (in "," val)
                    (get (.split val ",") 0)
                    val)]
    (if (not (in "." num-val))
        (float (get (re.findall r"(\d+)" num-val) 0))
        (float (get (re.findall r"(\d+\.\d)" num-val) 0)))))

;; Create instances from the attributes!
(with [onto]
  
  ; Log failures to a file for further reference
  (with [f (open "errors.txt" "w")]
    (for [(, k v) (all-heads.items)]

      ; Create/Name instance
      (setv drum-head (Drumhead (k.replace " " "_")))

      ; Attack
      (try
        (let [attack-lst []]
          (for [attack-val (.split (get v "Attack") ",")]
            (cond [(= attack-val "Very Low") (attack-lst.append VeryLowAttack)]
                  [(= attack-val "Low") (attack-lst.append LowAttack)]
                  [(= attack-val "Moderate") (attack-lst.append ModerateAttack)]
                  [(= attack-val "High") (attack-lst.append HighAttack)]
                  [(= attack-val "Very High") (attack-lst.append VeryHighAttack)]))
          (setv (. drum-head has-attack) attack-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Attack' key.\n")))

      ; Durability
      (try
        (let [dur-val (get v "Durability")]
          (cond [(= dur-val "Very Low") (setv (. drum-head durability) VeryLowDurability)]
                [(= dur-val "Low") (setv (. drum-head durability) LowDurability)]
                [(= dur-val "Medium") (setv (. drum-head durability) MediumDurability)]
                [(= dur-val "High") (setv (. drum-head durability) HighDurability)]
                [(= dur-val "Very High") (setv (. drum-head durability) VeryHighDurability)]
                [(= dur-val "Extreme") (setv (. drum-head durability) ExtremeDurability)]))
        (except [KeyError]
          (f.write f"{k} is missing the 'Durability' key.\n")))

      ; Overtones
      (try
        (let [ot-lst []]
          (for [ot-val (.split (get v "Overtones") ",")]
            (cond [(= ot-val "Very Low") (ot-lst.append VeryLowOvertones)]
                  [(= ot-val "Low") (ot-lst.append LowOvertones)]
                  [(= ot-val "Moderate") (ot-lst.append ModerateOvertones)]
                  [(= ot-val "High") (ot-lst.append HighOvertones)]
                  [(= ot-val "Very High") (ot-lst.append VeryHighOvertones)]))
          (setv (. drum-head has-overtones) ot-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Overtones' key.\n")))

      ; Responsiveness
      (try
        (let [resp-val (get v "Responsiveness")]
          (cond [(= resp-val "Very Low") (setv (. drum-head has-responsiveness)
                                               VeryLowResponsiveness)]
                [(= resp-val "Low") (setv (. drum-head has-responsiveness) LowResponsiveness)]
                [(= resp-val "Moderate") (setv (. drum-head has-responsiveness)
                                               ModerateResponsiveness)]
                [(= resp-val "High") (setv (. drum-head has-responsiveness) HighResponsiveness)]
                [(= resp-val "Very High") (setv (. drum-head has-responsiveness)
                                                VeryHighResponsiveness)]))
        (except [KeyError]
          (f.write f"{k} is missing the 'Responsiveness' key.\n")))

      ; Sound
      (try
        (let [sound-lst []]
          (for [sound-val (.split (get v "Sound") ",")]
            (cond [(= sound-val "Very Warm") (sound-lst.append VeryWarm)]
                  [(= sound-val "Warm") (sound-lst.append Warm)]
                  [(= sound-val "Balanced") (sound-lst.append Balanced)]
                  [(= sound-val "Bright") (sound-lst.append Bright)]
                  [(= sound-val "Very Bright") (sound-lst.append VeryBright)]))
          (setv (. drum-head has-sound) sound-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Sound' key.\n")))

      ; Sustain
      (try
        (let [sustain-lst []]
          (for [sustain-val (.split (get v "Sustain") ",")]
            (cond [(= sustain-val "Very Low") (sustain-lst.append VeryLowSustain)]
                  [(= sustain-val "Low") (sustain-lst.append LowSustain)]
                  [(= sustain-val "Moderate") (sustain-lst.append ModerateSustain)]
                  [(= sustain-val "High") (sustain-lst.append HighSustain)]
                  [(= sustain-val "Very High") (sustain-lst.append VeryHighSustain)]))
          (setv (. drum-head has-sustain) sustain-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Sustain' key.\n")))

      ; Drum(s)
      (try
        (let [drum-lst []]
          (for [drum-val (.split (get v "Drum") ",")]
            (cond [(= drum-val "Snare Drum") (drum-lst.append SnareDrum)]
                  [(= drum-val "Snare Side Resonant") (drum-lst.append SnareDrum)]
                  [(= drum-val "Bass Drum") (drum-lst.append BassDrum)]
                  [(= drum-val "Toms") (drum-lst.append TomTom)]
                  [(= drum-val "Bucket") (drum-lst.append Bucket)]))
          (setv (. drum-head goes-on) drum-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Drum' key.")))

      ; Ply (there really, REALLY should only be one!)
      (try
        (setv (. drum-head has-plies) (extract-number (get-default v "Ply")))
        (except [KeyError]
          (f.write f"{k} is missing the 'Ply' key.\n")))

      ; Thickness
      (try
        (setv (. drum-head has-thickness) (extract-number (get v "Total Thickness")))
        (except [KeyError]
          (f.write f"{k} is missing the 'Thickness' key.\n")))

      ; Surface
      (try
        (let [surface-lst []]
          (for [surface-val (.split (get v "Surface") ",")]
            (cond [(= surface-val "Synthetic Fiber") (surface-lst.append SimulatedSkin)]
                  [(= surface-val "Coated") (surface-lst.append Coated)]
                  [(= surface-val "Clear") (surface-lst.append Clear)]
                  [(= surface-val "Etched") (surface-lst.append Etched)]
                  [(= surface-val "Suede") (surface-lst.append Suede)]
                  [(= surface-val "Hazy") (surface-lst.append Hazy)]
                  [(= surface-val "Frosted") (surface-lst.append Frosted)]
                  [(= surface-val "Ebony") (surface-lst.append Ebony)]))
          (setv (. drum-head has-surface) surface-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Surface' key.\n")))

      ; Dampening
      (try
        (let [damp-lst []]
          (for [damp-val (.split (get v "Special Features") ",")]
            (cond [(= damp-val "Control Dot (topside)") (damp-lst.append CenterDot)]
                  [(= damp-val "Control Dot (underside)") (damp-lst.append ReverseDot)]
                  [(= damp-val "Control Ring(s)") (damp-lst.append ControlRing)]
                  [(= damp-val "Removable Dampening")
                   (damp-lst.append RemovableDampening)]
                  [(= damp-val "Oil Dampening") (damp-lst.append Oil)]
                  [(= damp-val "Drilled Vent Holes") (damp-lst.append Holes)]
                  [(= damp-val "Inlay Ring(s)") (damp-lst.append InlayRing)]
                  [True (f.write f"{k} has additional special feature(s): {damp-val}")]))
          (setv (. drum-head has-dampening) damp-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Special Features' key.\n"))))))

(onto.save "test_ontologies/drums_cymbals.owl")

