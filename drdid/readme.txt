TITLE
      'DRDID': Module for the estimation of Doubly Robust Difference-in-Difference 

DESCRIPTION/AUTHOR(S)
      
    'DRDID' is a command that implements Sant'Anna and Zhao (2020) proposed estimators for the Average Treatment Effect on the Treated (ATT) in Difference-in-Differences (DID) setups where the parallel trends assumption holds after conditioning on a vector of pre-treatment covariates. For a generalization to multiple periods see CSDID.
    The main estimators in DRDID are locally efficient and doubly-robust estimators, because they combine Inverse probability weighting and outcome regression to estimate ATT's.
    DRDID can be applied to both balanced/unbalanced panel data, or repeated cross-section.
 
      KW: Differences in Differences
      KW: DID
      KW: Pretreatment Convariates
      KW: csdid
      KW: drdid
      
      Requires: Stata version 14
      
      Author:  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support: email  friosavi@levy.org
      
      Author:  Pedro H.C. Sant'Anna, Vanderbilt University and Microsoft

      Author:  Asjad Naqvi, International Institute for Applied Systems Analysis.

Files:
drdid.ado; drdid.sthlp; _gmm_dripw.ado;_gmm_regipw.ado;_het_did_gmm.ado
