
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/data/tarjetas.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/pages/tarjeta_page.dart';
import 'package:stripe_app/widgets/total_pay_button.dart';

import '../services/stripe_service.dart';

class HomePage extends StatelessWidget{
  final stripeService = new StripeService();

  @override
  Widget build(BuildContext context) {
    final pagarBloc = context.read<PagarBloc>();

    final size = MediaQuery.of(context).size;
    return Scaffold(appBar: AppBar(centerTitle: true,
    actions: [
      IconButton(onPressed: () async{
        mostrarLoading(context);
        /*await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);*/
        final resp = await stripeService.pagarConNuevaTarjeta(amount: pagarBloc.state.montoPagarString, 
        currency: pagarBloc.state.moneda);

         Navigator.pop(context);
        if(resp.ok){
          mostrarAlerta(context, 'Tarjeta OK','Todo correcto');
        }else{
          mostrarAlerta(context, 'Algo salió mal',resp.msg!);
        }
        
      }, icon: Icon(Icons.add))
    ],
      title: Text('Pagar'),),
      body: Stack(
        children: [
          Positioned(
            width: size.width,
            height: size.height,
            top: 200,
            child: PageView.builder(controller: PageController(viewportFraction: 0.8),
              physics: BouncingScrollPhysics(),
              itemCount: tarjetas.length,
              itemBuilder: (_, i){
              final tarjeta = tarjetas[i];
              return GestureDetector(
                onTap: (){
                  BlocProvider.of<PagarBloc>(context).add(OnSeleccionarTarjeta(tarjeta));
                  Navigator.push(context, navegarFadeIn(context, TarjetaPage()));
                },
                child: Hero(
                  tag: tarjeta.cardNumber,
                  child: CreditCardWidget(cardNumber: tarjeta.cardNumberHidden, expiryDate: tarjeta.expiracyDate, 
                  cardHolderName: tarjeta.cardHolderName, cvvCode: tarjeta.cvv, showBackView: false,
                  onCreditCardWidgetChange:(cardBrand){}),
                ),
              );
            }),
          ),
          Positioned(bottom: 0,
            child:TotalPayButton())
        ],
      ));
  }
  
}