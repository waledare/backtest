module Print where
import Text.PrettyPrint.Boxes
import Lib
import OptPort
import Ledger
import Data.Time
import Portfolio
import Text.Printf

alignExp :: String -> String
alignExp ns = 
    let 
        fs = break (=='e')
        fi = \x -> if (length (snd x)) == 3 
                   then x else (fst x, 
                        [head (snd x)] ++"0"++(tail (snd x)))
        fc = \(x,y) -> x ++ y
    in (fc . fi . fs) ns

printResult :: Double -> [Pair Day Day] -> [Portfolio] -> Box
printResult startWealth linkedDates portfolios =
    let dh  = text "Dates"
        vh  = text "Value"
        ul  = text "-------"
        ull  = text "----------"
        std = showGregorian $ (\(Pair x) -> fst x) (linkedDates!!0)
        tlp = text . (\x -> x::String) . printf "%.2f"
        g   = map (text . showGregorian) . uninterLink 2 
        f   = map (tlp . portValue) 
        dts = [dh, ull] ++ [text std] ++ (g linkedDates)
        pvs = [vh, ul] ++ [tlp startWealth] ++ (f portfolios)
    in  (vcat left dts) <+> 
        (emptyBox (length portfolios) 4) <+> (vcat right pvs)

printTable :: Box -> IO()
printTable box = 
    putStrLn ""
    >> printBox box
    >> putStrLn ""

printLedger :: Ledger -> IO()
printLedger ledger = 
        let bf   = text . (\x -> x::String) . printf "%.0f%%" . (100*) 
            df   = text . (\x -> x::String) . printf "%.2f" 
            pf   = text . (\x -> x::String) . printf "%.2f" 
            dtf  = text . showGregorian  
            getd x  = map df (x ledger) 
            getp :: (Ledger -> [Double]) -> [Box] 
            getp x  = map pf (x ledger) 
            gets :: (Ledger -> [Double]) -> [Box] 
            gets x  = map bf (x ledger) 
            [bs, es, bp, ep, npl] =  [gets begStats, gets endStats,  
                getp begPrices,  getp endPrices, getd netPnLs]
            iff = text . show
            geti x   = map iff (x ledger) 
            [esh, bsh] = map geti [endShares, begShares]
            bd = map dtf $ begDate ledger
            ed = map dtf $ endDate ledger
            esyms = map text $ endSymbols ledger 
            bsyms = map text $ begSymbols ledger 
            total = totalPnL ledger
            body =  vcat left  bsyms <+> vcat left bd    <+>  
                    vcat left esyms  <+> vcat left ed    <+> vcat right bp  <+> 
                    vcat right ep    <+> vcat right bs   <+> vcat right es  <+> 
                    vcat right bsh   <+> vcat right esh  <+> vcat right npl 
        in  putStrLn ("\n\nBalancing date: " ++ (showGregorian . head . endDate) ledger  ++ "\n") >> printBox body >> putStrLn ("\nNet Gain: " ++ printf "%.2f" total::String)

