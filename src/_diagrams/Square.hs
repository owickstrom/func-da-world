{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE TypeFamilies              #-}

{-# OPTIONS_GHC -Wno-missing-signatures #-}
module Main where

import           Data.List                      (intercalate)
import           Data.List.NonEmpty             (NonEmpty (..), toList)
import           Data.Typeable
-- import           Diagrams.Backend.SVG.CmdLine
import           Diagrams.Backend.Cairo.CmdLine
import           Diagrams.Prelude

data Id = Id [Int]
  deriving (Typeable, Eq, Ord, Show)

instance IsName Id

addToId :: Id -> Int -> Id
addToId (Id ids) i = Id (ids <> [i])

prettyPrintId :: Id -> String
prettyPrintId (Id ids) = intercalate "." (map show ids)

newtype Timeline = Timeline (NonEmpty Sequence)

newtype Sequence = Sequence (NonEmpty Parallel)

data Parallel = Parallel { videoTrack :: Track, audioTrack :: Track }

data Track = Track MediaType [Part]

data Implicitness = Explicit | Implicit

type PartDuration = Double

data Part = Clip PartDuration | Gap Implicitness PartDuration

data MediaType = Video | Audio

textHeight = 1

lineHeight = textHeight * 1.2

defaultSpacing = 2.5

timelineBg    = sRGB24 250 250 250
sequenceBg    = sRGB24 240 240 240
parallelBg    = white
parallelLc    = sRGB24 100 100 100
videoClipBg   = sRGB24 68  208 98
videoClipLc   = darken 0.2 videoClipBg
audioClipBg   = sRGB24 252 214 22
audioClipLc   = darken 0.2 audioClipBg
explicitGapBg = sRGB24 150 150 150
implicitGapBg = sRGB24 200 200 200
gapLc = darken 0.2 explicitGapBg

renderLabel lbl w =
  strutY (defaultSpacing - lineHeight)
  ===
  (text' <> alignBL (strutX w <> strutY lineHeight))

  where
    text' =
      alignedText 0 0 lbl
      # font "Linux Biolinum"

renderTrack :: Track -> Diagram B
renderTrack (Track _ []) = strut 1
renderTrack (Track mt parts') = map renderPart parts' # hcat # alignL
 where
  renderPart (Clip dur) =
    rect (dur * 2) 3 # bg (partColor mt) # lc (partLineColor mt)
  renderPart (Gap impl dur) =
    rect (dur * 2) 3 # gapStyle impl
  partColor Video = videoClipBg
  partColor Audio = audioClipBg
  partLineColor Video = videoClipLc
  partLineColor Audio = audioClipLc
  gapStyle Implicit = bg implicitGapBg . lc gapLc . dashingN [0.005, 0.005] 1
  gapStyle Explicit = bg explicitGapBg . lc gapLc

renderParallel :: Id -> Parallel -> Diagram B
renderParallel id' parallel = alignL lblText === alignL boxedTracks
 where
  vtBox  = renderTrack (videoTrack parallel)
  atBox  = renderTrack (audioTrack parallel)
  tracks =
    vsep 1 [vtBox, atBox]
    # frame 1
  bgBox       =
    boundingRect tracks
    # lc parallelLc
    # bg parallelBg
  boxedTracks =
    (tracks <> bgBox)
    # center
    # named id'
  lblText = renderLabel ("Parallel " <> prettyPrintId id') (width boxedTracks)

padLRB pad' dia= strutX pad' ||| (dia === strutY pad') ||| strutX pad'

renderSequence :: Id -> Sequence -> Diagram B
renderSequence id' (Sequence parallels) = alignL lblText === alignL boxedParallels
 where
  parallels' =
    parallels
    # toList
    # zipWith (renderParallel . addToId id') [1..]
    # hsep defaultSpacing
    # padLRB defaultSpacing
  bgBox =
    boundingRect parallels'
    # bg sequenceBg
    # lc darkgrey
  boxedParallels =
    (parallels' <> bgBox)
    # center
    # named id'
  lblText = renderLabel ("Sequence " <> prettyPrintId id') (width boxedParallels)

renderTimeline :: Timeline -> Diagram B
renderTimeline (Timeline sequences) = padLRB defaultSpacing (alignL lblText === alignL boxedSequences)
 where
  sequences' =
    sequences
    # toList
    # zipWith (renderSequence . Id . pure ) [1..]
    # hsep defaultSpacing
    # padLRB defaultSpacing
  bgBox =
    boundingRect sequences'
    # bg timelineBg
    # lc darkgrey
  boxedSequences =
    (sequences' <> bgBox)
    # center
  lblText = renderLabel "Timeline" (width boxedSequences)

timeline = renderTimeline
  (Timeline (s1 :| [s1]))
  where
    s1 =
      Sequence
       (  Parallel
         (Track Video [Clip 2, Gap Explicit 0.5, Clip 1, Gap Implicit 1.5])
         (Track Audio [Clip 4, Gap Explicit 1])

         :| [ Parallel (Track Video [Gap Explicit 1, Clip 4.5])
              (Track Audio [Clip 1.2, Gap Implicit 4.3])
            ]
       )


timelineWithArrows =
  -- TODO: Automate this
  timeline
  # connectArr (Id [1]) (Id [2])
  # connectArr (Id [1, 1]) (Id [1, 2])
  # connectArr (Id [2, 1]) (Id [2, 2])
  where
    connectArr =
      connectOutside' (with & arrowHead .~ tri
                            & headLength .~ small)

main :: IO ()
main = multiMain [("timeline", timelineWithArrows)]
