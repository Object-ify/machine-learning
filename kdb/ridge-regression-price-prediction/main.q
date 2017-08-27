/*****************************************************************************
/*                                                                           *
/*                       Machine Learning API Framework                      *
/*                                                                           *
/*****************************************************************************
//
//  File Name:  main.q
//
//  Purpose:    This module applies ridge regression to a dataset
//
//  Author:     Joel Oliveira, First Derivatives
//
//  Revision History
//
//  Date        Author              Description
//  -------     ------------------  -----------------------------------------
//  15Aug17     Joel Oliveira       Original version

\d .ml
\l dataset.q

// Train model function
trainModel:{[]

    train::([] intercept:(count train)#1.0),'train;
    columns:cols train;
    f:flip 0^"f"$train[columns[where (columns<>`SalePrice)]];

    //build the weight.
    weight::"f"$((count f[0]),1)#(10000),(-1 + count f[0])#0.0;

    // Get the operator (SalePrice)
    sp:0^"f"$train[`SalePrice];

    show "Executing ridge regression";
    // Ridge L2 regression function
    100{[f;sp;x] weight::weight-"f"$1.0e-12*((2*(flip f)$((f$weight)-sp))+(2*0.0*weight))}[f;sp]\0;

    };

// Run regression model with trained weights on test data
output:{[]
    test::([]intercept:(count test)#1.0),'test;
    l:cols train;
    k:raze where each l =/: cols test;
    columns:l[k];
    wts:weight[k];
    h:((count columns),1)# raze over (columns!wts)@columns;
    f:flip 0f^/:"f"$test[columns];
    show ([]Id:testId;SalePrice:f$h);
    };


// Load and clean the training dataset
loadTrainDataset[];

// Load and clean the test dataset
loadTestDataset[];

// Train the model
trainModel[];

// Show the results
output[];

\d .